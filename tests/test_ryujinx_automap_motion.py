"""Offline regressions; no emulator, Steam session or user config is accessed.

Run: python3 -m unittest discover -s tests -p 'test_ryujinx_automap_motion.py' -v
Set EMUDECK_TEST_ROOT to run the same cases against the unpatched source.
Requires bash and jq. SDL calls are replaced by a capability fixture.
"""
import contextlib
import ctypes
import io
import json
import os
from pathlib import Path
import runpy
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(os.environ.get('EMUDECK_TEST_ROOT', Path(__file__).resolve().parents[1]))
FILTER = '0x28de/0x11ff'


def pad(name, ident, motion=False, player='Player1'):
    return dict(name=name, id=ident, has_motion=motion, player=player)


class AutoMapTests(unittest.TestCase):
    def run_case(self, default, native, *, count=1, auto='true', product='Fremont',
                 backend='CemuHook', motion=True, native_error=False, layout='abxy', initial_nintendo=False, custom_buttons=None):
        config = {'input_config': [{
            'backend': 'GamepadSDL3', 'id': 'previous', 'name': 'Previous',
            'player_index': 'Player1', 'controller_type': 'ProController',
            'right_joycon': dict(button_x='X', button_b='B', button_y='Y', button_a='A'),
            'motion': dict(motion_backend=backend, enable_motion=motion, sensitivity=75, gyro_deadzone=2),
        }]}
        if initial_nintendo:
            config['input_config'][0]['right_joycon'] = dict(button_x='Y', button_b='A', button_y='X', button_a='B')
        if custom_buttons:
            config['input_config'][0]['right_joycon'].update(custom_buttons)
        shell = r'''
source "$1"
Ryujinx_configFile="$CASE_CONFIG"
getProductName() { printf '%s\n' "$CASE_PRODUCT"; }
Ryujinx_gamepadCount() { printf '%s\n' "$CASE_COUNT"; }
Ryujinx_getOrderedGamepads() {
    if [ "$SDL_GAMECONTROLLER_IGNORE_DEVICES" = "0x28de/0x11ff" ]; then
        [ "$CASE_NATIVE_ERROR" = "1" ] && return 1
        printf '%s\n' "$CASE_NATIVE"
    else
        printf '%s\n' "$CASE_DEFAULT"
    fi
}
Ryujinx_set_gamepad_name
result=$?
printf '%s\n%s\n' "$SDL_GAMECONTROLLER_IGNORE_DEVICES" "$SDL_JOYSTICK_IGNORE_DEVICES" > "$CASE_ENV"
exit "$result"
'''
        with tempfile.TemporaryDirectory(prefix='automap-test-') as directory:
            config_path = Path(directory) / 'Config.json'
            env_path = Path(directory) / 'environment'
            config_path.write_text(json.dumps(config, indent=2) + '\n')
            original = config_path.read_bytes()
            env = os.environ.copy()
            env.update(CASE_CONFIG=str(config_path), CASE_ENV=str(env_path),
                       CASE_PRODUCT=product, CASE_COUNT=str(count),
                       CASE_DEFAULT=json.dumps(default), CASE_NATIVE=json.dumps(native),
                       CASE_NATIVE_ERROR=str(int(native_error)), autoMapSwitch=auto,
                       controllerLayout=layout, SDL_GAMECONTROLLER_IGNORE_DEVICES='steam-list',
                       SDL_JOYSTICK_IGNORE_DEVICES='user-list')
            result = subprocess.run(['bash', '-c', shell, 'test', str(ROOT / 'functions/EmuScripts/emuDeckRyujinx.sh')],
                                    env=env, capture_output=True, text=True, timeout=10)
            return (json.loads(config_path.read_text()), env_path.read_text().splitlines(),
                    original == config_path.read_bytes(), result)

    def test_one_native_motion_controller_preserves_layout(self):
        for name in ['Steam Controller', 'DualSense Wireless Controller']:
            with self.subTest(name=name):
                result, environment, _, process = self.run_case(
                    [pad('Steam Virtual Gamepad', 'virtual')], [pad(name, 'native', True)])
                self.assertEqual(process.returncode, 0, process.stderr)
                controller = result['input_config'][0]
                self.assertEqual(controller['id'], 'native')
                self.assertEqual(controller['motion'], dict(motion_backend='GamepadDriver',
                                 sensitivity=75, gyro_deadzone=2, enable_motion=True))
                self.assertEqual(controller['right_joycon']['button_a'], 'A')
                self.assertEqual(environment, [FILTER, FILTER])

    def test_missing_sensor_or_ambiguous_native_keeps_steam_path(self):
        for native in [[], [pad('Xbox', 'native')], [pad('One', 'one', True), pad('Two', 'two', True)]]:
            with self.subTest(native=native):
                result, environment, _, process = self.run_case([pad('Virtual', 'virtual')], native)
                self.assertEqual(process.returncode, 0, process.stderr)
                self.assertEqual(result['input_config'][0]['id'], 'virtual')
                self.assertEqual(environment, ['steam-list', 'user-list'])

    def test_failed_native_probe_keeps_steam_path(self):
        result, environment, _, process = self.run_case([pad('Virtual', 'virtual')], [], native_error=True)
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertEqual(result['input_config'][0]['id'], 'virtual')
        self.assertEqual(environment, ['steam-list', 'user-list'])

    def test_disabled_automap_does_not_touch_config_or_environment(self):
        _, environment, unchanged, process = self.run_case([], [], auto='false')
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertTrue(unchanged)
        self.assertEqual(environment, ['steam-list', 'user-list'])

    def test_handheld_default_without_opt_in_is_unchanged(self):
        for product in ['Jupiter', 'Galileo']:
            with self.subTest(product=product):
                _, environment, unchanged, process = self.run_case([], [], auto='', product=product)
                self.assertEqual(process.returncode, 0, process.stderr)
                self.assertTrue(unchanged)
                self.assertEqual(environment, ['steam-list', 'user-list'])

    def test_deck_alone_retains_dsu(self):
        deck = [pad('Steam Deck (0)', 'deck')]
        result, _, _, process = self.run_case(deck, deck, product='Jupiter', backend='GamepadDriver')
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertEqual(result['input_config'][0]['motion']['motion_backend'], 'CemuHook')

    def test_deck_and_external_controller_use_their_own_motion_backends(self):
        native = [pad('External gyro controller', 'external', True), pad('Steam Deck (0)', 'deck', player='Player2')]
        result, _, _, process = self.run_case([], native, count=2, backend='GamepadDriver', product='Jupiter')
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertEqual([p['motion']['motion_backend'] for p in result['input_config']], ['GamepadDriver', 'CemuHook'])
        self.assertEqual([p['player_index'] for p in result['input_config']], ['Player1', 'Player2'])

    def test_four_players_and_motion_preference_remain_available(self):
        native = [pad('Controller '+str(i), str(i), i == 1, 'Player'+str(i)) for i in range(1, 5)]
        result, environment, _, process = self.run_case([], native, count=4, motion=False)
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertEqual([p['id'] for p in result['input_config']], ['1', '2', '3', '4'])
        self.assertFalse(result['input_config'][0]['motion']['enable_motion'])
        self.assertEqual(environment, [FILTER, FILTER])

    def test_no_controller_returns_failure_without_fabricating_one(self):
        _, environment, unchanged, process = self.run_case([], [], count=0, initial_nintendo=True)
        self.assertNotEqual(process.returncode, 0)
        self.assertTrue(unchanged)
        self.assertEqual(environment, ['steam-list', 'user-list'])

    def test_failed_multi_controller_probe_preserves_layout_and_filters(self):
        _, environment, unchanged, process = self.run_case(
            [], [], count=2, native_error=True, initial_nintendo=True)
        self.assertNotEqual(process.returncode, 0)
        self.assertTrue(unchanged)
        self.assertEqual(environment, ['steam-list', 'user-list'])

    def test_both_layout_preferences(self):
        for layout, expected in [('abxy', 'A'), ('bayx', 'B'), ('baxy', 'B')]:
            with self.subTest(layout=layout):
                config, _, _, process = self.run_case(
                    [pad('Virtual', 'virtual')], [pad('Native', 'native', True)], layout=layout)
                self.assertEqual(process.returncode, 0, process.stderr)
                self.assertEqual(config['input_config'][0]['right_joycon']['button_a'], expected)

    def test_non_abxy_custom_bindings_are_preserved(self):
        config, _, _, process = self.run_case(
            [pad('Virtual', 'virtual')], [pad('Native', 'native', True)],
            custom_buttons={'button_a': 'RightShoulder', 'button_plus': 'Start'})
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertEqual(config['input_config'][0]['right_joycon']['button_a'], 'RightShoulder')
        self.assertEqual(config['input_config'][0]['right_joycon']['button_plus'], 'Start')


class Function:
    def __init__(self, callback):
        self.callback = callback

    def __call__(self, *args):
        return self.callback(*args)


class FakeSDL:
    def __init__(self, devices):
        self.devices = devices
        self.opened = []
        self.closed = []
        self.quit_called = False
        self.SDL_Init = Function(lambda flags: True)
        self.SDL_GetGamepads = Function(self.get_gamepads)
        self.SDL_GetJoystickNameForID = Function(lambda ident: devices[ident - 1]['name'].encode())
        self.SDL_GetJoystickGUIDForID = Function(self.get_guid)
        self.SDL_GetError = Function(lambda: b'fixture')
        self.SDL_OpenGamepad = Function(self.open)
        self.SDL_GamepadHasSensor = Function(lambda ident, sensor: sensor == 2 and devices[ident - 1].get('gyro', False))
        self.SDL_CloseGamepad = Function(lambda ident: self.closed.append(ident))
        self.SDL_Quit = Function(self.quit)

    def get_gamepads(self, count):
        count._obj.value = len(self.devices)
        return (ctypes.c_uint32 * len(self.devices))(*range(1, len(self.devices) + 1))

    def get_guid(self, ident):
        device = self.devices[ident - 1]
        raw = bytearray(16)
        raw[0:2] = (3).to_bytes(2, 'little')
        raw[4:6] = device['vendor'].to_bytes(2, 'little')
        raw[8:10] = device['product'].to_bytes(2, 'little')
        return self.SDL_GetJoystickGUIDForID.restype((ctypes.c_uint8 * 16)(*raw))

    def open(self, ident):
        self.opened.append(ident)
        return 0 if self.devices[ident - 1].get('open_error') else ident

    def quit(self):
        self.quit_called = True


class EnumerationTests(unittest.TestCase):
    def enumerate(self, devices, arguments=()):
        driver = FakeSDL(devices)
        output = io.StringIO()
        with patch('ctypes.CDLL', return_value=driver), patch.dict(os.environ, {'SDL_LIB': 'fixture'}), \
                patch('sys.argv', ['ryujinxGamepads.py', *arguments]), contextlib.redirect_stdout(output):
            try:
                runpy.run_path(str(ROOT / 'tools/gamepads/ryujinxGamepads.py'), run_name='__main__')
            except SystemExit as error:
                self.assertEqual(error.code, 0)
        self.assertTrue(driver.quit_called)
        return json.loads(output.getvalue()), driver

    def test_capability_probe_with_sensorless_and_handheld_controls(self):
        devices = [
            dict(name='Steam Controller', vendor=0x28de, product=0x1305, gyro=True),
            dict(name='Different gyro model', vendor=0x054c, product=0x0ce6, gyro=True),
            dict(name='Xbox', vendor=0x045e, product=0x028e),
            dict(name='Steam Deck', vendor=0x28de, product=0x1205, gyro=True),
        ]
        result, driver = self.enumerate(devices)
        self.assertEqual([p['has_motion'] for p in result], [True, True, False, False])
        self.assertEqual(driver.opened, [1, 2, 3])
        self.assertEqual(driver.closed, driver.opened)

    def test_virtual_guid_and_failed_open_do_not_claim_motion(self):
        result, driver = self.enumerate([
            dict(name='Steam Controller', vendor=0x28de, product=0x11ff, gyro=True),
            dict(name='Unavailable controller', vendor=0x054c, product=0x0ce6, gyro=True, open_error=True),
        ])
        self.assertEqual([p['has_motion'] for p in result], [False, False])
        self.assertEqual(driver.opened, [2])
        self.assertEqual(driver.closed, [])

    def test_count_does_not_open_devices(self):
        count, driver = self.enumerate([dict(name='Steam Deck', vendor=0x28de, product=0x1205)], ['--count'])
        self.assertEqual(count, 1)
        self.assertEqual(driver.opened, [])


if __name__ == '__main__':
    unittest.main()
