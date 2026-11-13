"""Routing regressions for AutoMap and modern Ryujinx configuration schemas.

Same invocation/fixtures can run against the unpatched source via
EMUDECK_TEST_ROOT. No installed configuration or actual controller is used.
"""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(os.environ.get('EMUDECK_TEST_ROOT', Path(__file__).resolve().parents[1]))


class AssignmentsTests(unittest.TestCase):
    def run_case(self, count=1, *, modern=True, enabled=True, dynamic=False, profile_error=False, repeat=False, profile_collision=False):
        original = {
            'unrelated_setting': 'preserve',
            'input_config': [{
                'backend': 'GamepadSDL3', 'id': 'old-device', 'name': 'Old',
                'player_index': 'Player1', 'controller_type': 'ProController',
                'enable_dynamic_gamepad_swap': dynamic,
                'right_joycon': dict(button_x='Y', button_b='A', button_y='X', button_a='B'),
                'motion': dict(motion_backend='GamepadDriver', enable_motion=True),
            }],
        }
        if modern:
            original['player_input_assignments'] = [
                {'player_index': player, 'enable_dynamic_input_swap': dynamic,
                 'devices': [{'type': 'Controller', 'id': ident, 'profile_name': 'Manual layout'}]}
                for player, ident in [('Player1', 'old-device'), ('Player2', 'removed-device')]
            ]
        pads = [dict(player='Player'+str(i), id='device-'+str(i), name='Pad '+str(i)) for i in range(1, count+1)]
        shell = r'''
source "$1"
Ryujinx_configFile="$TEST_CONFIG"
getProductName() { echo GenericDesktop; }
Ryujinx_gamepadCount() { echo "$TEST_COUNT"; }
Ryujinx_getOrderedGamepads() { printf '%s\n' "$TEST_PADS"; }
Ryujinx_set_gamepad_name
'''
        with tempfile.TemporaryDirectory(prefix='automap-assignments-') as directory:
            path = Path(directory) / 'Config.json'
            path.write_text(json.dumps(original, indent=2)+'\n')
            manual = Path(directory)/'profiles/controller/My manual layout.json'
            manual.parent.mkdir(parents=True)
            manual.write_text('{"keep": true}')
            if profile_error:
                manual.unlink()
                manual.parent.rmdir()
                manual.parent.write_text('occupied')
            if profile_collision:
                (manual.parent/'EmuDeck AutoMap - Player1.json').mkdir()
            before = path.read_bytes()
            env = os.environ.copy()
            env.update(TEST_CONFIG=str(path), TEST_COUNT=str(count), TEST_PADS=json.dumps(pads),
                       autoMapSwitch=str(enabled).lower(), controllerLayout='abxy')
            p = subprocess.run(['bash', '-c', shell, 'test', str(ROOT/'functions/EmuScripts/emuDeckRyujinx.sh')],
                               env=env, capture_output=True, text=True, timeout=10)
            if profile_error or profile_collision:
                self.assertNotEqual(p.returncode, 0)
                self.assertEqual(path.read_bytes(), before)
                return
            self.assertEqual(p.returncode, 0, p.stderr)
            if repeat:
                again = subprocess.run(['bash', '-c', shell, 'test', str(ROOT/'functions/EmuScripts/emuDeckRyujinx.sh')],
                                       env=env, capture_output=True, text=True, timeout=10)
                self.assertEqual(again.returncode, 0, again.stderr)
            result = json.loads(path.read_text())
            self.assertEqual(manual.read_text(), '{"keep": true}')
            if modern and enabled:
                for item, route in zip(result['input_config'], result['player_input_assignments']):
                    name = route['devices'][0]['profile_name']
                    self.assertTrue(name, 'A null binding reloads Nintendo defaults in Ryujinx UI')
                    profile = json.loads((manual.parent/(name+'.json')).read_text())
                    self.assertEqual(profile, item)
                    self.assertEqual(profile['right_joycon']['button_a'], 'A')
                    self.assertEqual(profile['motion'], item['motion'])
            else:
                self.assertEqual(list(manual.parent.glob('EmuDeck AutoMap*.json')), [])
            self.assertEqual(result['unrelated_setting'], 'preserve')
            return original, result, before == path.read_bytes()

    def test_one_player_replaces_stale_device_and_removes_extra_route(self):
        _, result, _ = self.run_case()
        self.assertEqual(result['player_input_assignments'], [{
            'player_index': 'Player1', 'enable_dynamic_input_swap': False,
            'devices': [{'type': 'Controller', 'id': 'device-1', 'profile_name': 'EmuDeck AutoMap - Player1'}],
        }])
        self.assertEqual(result['input_config'][0]['right_joycon']['button_a'], 'A')

    def test_four_players_have_matching_routes_without_cross_player_fallback(self):
        _, result, _ = self.run_case(count=4, dynamic=True)
        self.assertEqual(len(result['player_input_assignments']), len(result['input_config']))
        for config, assignment in zip(result['input_config'], result['player_input_assignments']):
            self.assertEqual(assignment['player_index'], config['player_index'])
            self.assertEqual(assignment['devices'], [{'type': 'Controller', 'id': config['id'], 'profile_name': 'EmuDeck AutoMap - '+config['player_index']}])
            self.assertFalse(assignment['enable_dynamic_input_swap'])
            self.assertFalse(config['enable_dynamic_gamepad_swap'])

    def test_disabled_automap_retains_manual_bindings_and_dynamic_settings(self):
        before, after, unchanged = self.run_case(enabled=False, dynamic=True)
        self.assertTrue(unchanged)
        self.assertEqual(before, after)

    def test_legacy_schema_does_not_acquire_new_routing_fields(self):
        _, result, _ = self.run_case(modern=False, dynamic=True)
        self.assertNotIn('player_input_assignments', result)
        self.assertTrue(result['input_config'][0]['enable_dynamic_gamepad_swap'])

    def test_profile_creation_failure_does_not_change_config(self):
        self.run_case(profile_error=True)

    def test_repeated_launch_refreshes_profiles_without_duplicates(self):
        self.run_case(count=4, repeat=True)

    def test_profile_directory_collision_is_not_treated_as_success(self):
        self.run_case(profile_collision=True)


if __name__ == '__main__':
    unittest.main()
