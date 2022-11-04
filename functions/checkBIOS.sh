#!/bin/bash

checkPS1BIOS(){		
	
	PSXBIOS="NULL"
	
	for entry in "$biosPath/"*
	do
		if [ -f "$entry" ]; then		
			md5=($(md5sum "$entry"))	
			if [[ "$PSXBIOS" != true ]]; then
				PSBios=(239665b1a3dade1b5a52c06338011044 2118230527a9f51bd9216e32fa912842 849515939161e62f6b866f6853006780 dc2b9bf8da62ec93e868cfd29f0d067d 54847e693405ffeb0359c6287434cbef cba733ceeff5aef5c32254f1d617fa62 da27e8b6dab242d8f91a9b25d80c63b8 417b34706319da7cf001e76e40136c23 57a06303dfa9cf9351222dfcbb4a29d9 81328b966e6dcf7ea1e32e55e1c104bb 924e392ed05558ffdb115408c263dccf e2110b8a2b97a8e0b857a45d32f7e187 ca5cfc321f916756e3f0effbfaeba13b 8dd7d5296a650fac7319bce665a6a53c 490f666e1afb15b7362b406ed1cea246 32736f17079d0b2b7024407c39bd3050 8e4c14f567745eff2f0408c8129f72a6 b84be139db3ee6cbd075630aa20a6553 1e68c231d0896b7eadcad1d7d8e76129 b9d9a0286c33dc6b7237bb13cd46fdee 8abc1b549a4a80954addc48ef02c4521 9a09ab7e49b422c007e6d54d7c49b965 b10f5e0e3d9eb60e5159690680b1e774 6e3735ff4c7dc899ee98981385f6f3d0 de93caec13d1a141a40a79f5c86168d6 c53ca5908936d412331790f4426c6c33 476d68a94ccec3b9c8303bbd1daf2810 d8f485717a5237285e4d7c5f881b7f32 fbb5f59ec332451debccf1e377017237 81bbe60ba7a3d1cea1d48c14cbcc647b)
				for i in "${PSBios[@]}"
				do
				if [[ "$md5" == *"${i}"* ]]; then
					PSXBIOS=true
					#mv "$entry" "${entry,,}"
					break
				else
					PSXBIOS=false
				fi
				done	
			fi		
		fi
	done	
		
	
	if [ $PSXBIOS == true ]; then
		echo "$entry true";
	else
		echo "false";
	fi	

}

checkPS2BIOS(){
	
	PS2BIOS="NULL"
	
	for entry in "$biosPath/"*
	do
		if [ -f "$entry" ]; then		
			md5=($(md5sum "$entry"))			
			if [[ "$PS2BIOS" != true ]]; then
				PS2Bios=(32f2e4d5ff5ee11072a6bc45530f5765 acf4730ceb38ac9d8c7d8e21f2614600 acf9968c8f596d2b15f42272082513d1 b1459d7446c69e3e97e6ace3ae23dd1c d3f1853a16c2ec18f3cd1ae655213308 63e6fd9b3c72e0d7b920e80cf76645cd a20c97c02210f16678ca3010127caf36 8db2fbbac7413bf3e7154c1e0715e565 91c87cb2f2eb6ce529a2360f80ce2457 3016b3dd42148a67e2c048595ca4d7ce b7fa11e87d51752a98b38e3e691cbf17 f63bc530bd7ad7c026fcd6f7bd0d9525 cee06bd68c333fc5768244eae77e4495 0bf988e9c7aaa4c051805b0fa6eb3387 8accc3c49ac45f5ae2c5db0adc854633 6f9a6feb749f0533aaae2cc45090b0ed 838544f12de9b0abc90811279ee223c8 bb6bbc850458fff08af30e969ffd0175 815ac991d8bc3b364696bead3457de7d b107b5710042abe887c0f6175f6e94bb ab55cceea548303c22c72570cfd4dd71 18bcaadb9ff74ed3add26cdf709fff2e 491209dd815ceee9de02dbbc408c06d6 7200a03d51cacc4c14fcdfdbc4898431 8359638e857c8bc18c3c18ac17d9cc3c 352d2ff9b3f68be7e6fa7e6dd8389346 d5ce2c7d119f563ce04bc04dbc3a323e 0d2228e6fd4fb639c9c39d077a9ec10c 72da56fccb8fcd77bba16d1b6f479914 5b1f47fbeb277c6be2fccdd6344ff2fd 315a4003535dfda689752cb25f24785c 312ad4816c232a9606e56f946bc0678a 666018ffec65c5c7e04796081295c6c7 6e69920fa6eef8522a1d688a11e41bc6 eb960de68f0c0f7f9fa083e9f79d0360 8aa12ce243210128c5074552d3b86251 240d4c5ddd4b54069bdc4a3cd2faf99d 1c6cd089e6c83da618fbf2a081eb4888 463d87789c555a4a7604e97d7db545d1 35461cecaa51712b300b2d6798825048 bd6415094e1ce9e05daabe85de807666 2e70ad008d4ec8549aada8002fdf42fb b53d51edc7fc086685e31b811dc32aad 1b6e631b536247756287b916f9396872 00da1b177096cfd2532c8fa22b43e667 afde410bd026c16be605a1ae4bd651fd 81f4336c1de607dd0865011c0447052e 0eee5d1c779aa50e94edd168b4ebf42e d333558cc14561c1fdc334c75d5f37b7 dc752f160044f2ed5fc1f4964db2a095 63ead1d74893bf7f36880af81f68a82d 3e3e030c0f600442fa05b94f87a1e238 1ad977bb539fc9448a08ab276a836bbc eb4f40fcf4911ede39c1bbfe91e7a89a 9959ad7a8685cad66206e7752ca23f8b 929a14baca1776b00869f983aa6e14d2 573f7d4a430c32b3cc0fd0c41e104bbd df63a604e8bff5b0599bd1a6c2721bd0 5b1ba4bb914406fae75ab8e38901684d cb801b7920a7d536ba07b6534d2433ca af60e6d1a939019d55e5b330d24b1c25 549a66d0c698635ca9fa3ab012da7129 5de9d0d730ff1e7ad122806335332524 21fe4cad111f7dc0f9af29477057f88d 40c11c063b3b9409aa5e4058e984e30c 80bbb237a6af9c611df43b16b930b683 c37bce95d32b2be480f87dd32704e664 80ac46fa7e77b8ab4366e86948e54f83 21038400dc633070a78ad53090c53017 dc69f0643a3030aaa4797501b483d6c4 30d56e79d89fbddf10938fa67fe3f34e 93ea3bcee4252627919175ff1b16a1d9 d3e81e95db25f5a86a7b7474550a2155)
				for i in "${PS2Bios[@]}"
				do
					if [[ "$md5" == *"${i}"* ]]; then
						PS2BIOS=true
						#mv "$entry" "${entry,,}"
						break
					else
						PS2BIOS=false
					fi
				done	
			fi
		fi
	done	
		
		
	if [ $PS2BIOS == true ]; then
		echo "true";
	else
		echo "false";
	fi	
}

checkYuzuBios(){
	
	FILE="$HOME/.local/share/yuzu/keys/prod.keys"
	if [ -f "$FILE" ]; then	
			echo "true";
	else
			echo "false";
	fi
}

checkSegaCDBios(){
	
	SEGACDBIOS="NULL"
	
	for entry in "$biosPath/"*
	do
		if [ -f "$entry" ]; then		
			md5=($(md5sum "$entry"))	
			if [[ "$SEGACDBIOS" != true ]]; then
				CDBios=(bc6ae4e1db01a2f349d9af392bf7e2bd 29ad9ce848b49d0f9cefc294137f653c cc049159d7e744c15eee080c241273b4 278a9397d192149e84e820ac621a8edd a3ddcc8483b0368141adfd99d9a1e466 bdeb4c47da613946d422d97d98b21cda 96ea588d647f2ab1f291279fc691663c 2efd74e3232ff260e371b99f84024f7f e66fa1dc5820d254611fdcdba0662372 683a8a9e273662561172468dfa2858eb 310a9081d2edf2d316ab38813136725e 9b562ebf2d095bf1dabadbc1881f519a 854b9150240a198070150e4566ae1290 b10c0a97abc57b758497d3fae6ab35a4 ecc837c31d77b774c6e27e38f828aa9a baca1df271d7c11fe50087c0358f4eb5)
				for i in "${CDBios[@]}"
				do
				if [[ "$md5" == *"${i}"* ]]; then
					SEGACDBIOS=true
					break
				else
					SEGACDBIOS=false
				fi
				done	
			fi		
		fi
	done	
		
	
	if [ $SEGACDBIOS == true ]; then
		echo "true";
	else
		echo "false";
	fi	
	
}

checkSaturnBios(){
	
	SATURNBIOS="NULL"
	
	for entry in "$biosPath/"*
	do
		if [ -f "$entry" ]; then		
			md5=($(md5sum "$entry"))	
			if [[ "$SATURNBIOS" != true ]]; then
				SaturnBios=(af5828fdff51384f99b3c4926be27762 85ec9ca47d8f6807718151cbcca8b964 f273555d7d91e8a5a6bfd9bcf066331c 3240872c70984b6cbfda1586cab68dbe ac4e4b6522e200c0d23d371a8cecbfd3 3ea3202e2634cb47cb90f3a05c015010 cb2cebc1b6e573b7c44523d037edcd45 0306c0e408d6682dd2d86324bd4ac661)
				for i in "${SaturnBios[@]}"
				do
				if [[ "$md5" == *"${i}"* ]]; then
					SATURNBIOS=true
					break
				else
					SATURNBIOS=false
				fi
				done	
			fi		
		fi
	done	
		
	
	if [ $SATURNBIOS == true ]; then		
		echo "true";
	else
		echo "false";
	fi	
	
}


checkDreamcastBios(){
	
	local BIOS="NULL"
	
	for entry in "$biosPath/dc/"*
	do
		if [ -f "$entry" ]; then		
			md5=($(md5sum "$entry"))	
			if [[ "$BIOS" != true ]]; then
				local hashes=(d407fcf70b56acb84b8c77c93b0e5327 e10c53c2f8b90bab96ead2d368858623 93a9766f14159b403178ac77417c6b68 0a93f7940c455905bea6e392dfde92a4)
				for i in "${hashes[@]}"
				do
				if [[ "$md5" == *"${i}"* ]]; then
					BIOS=true
					break
				else
					BIOS=false
				fi
				done	
			fi		
		fi
	done	
		
	
	if [ $BIOS == true ]; then		
		echo "true";
	else
		echo "false";
	fi	
	
}

checkDSBios(){
	
	local BIOS="NULL"
	
	for entry in "$biosPath/"*
	do
		if [ -f "$entry" ]; then		
			md5=($(md5sum "$entry"))	
			if [[ "$BIOS" != true ]]; then
				local hashes=(145eaef5bd3037cbc247c213bb3da1b3 df692a80a5b1bc90728bc3dfc76cd948 a392174eb3e572fed6447e956bde4b25)
				for i in "${hashes[@]}"
				do
				if [[ "$md5" == *"${i}"* ]]; then
					BIOS=true
					break
				else
					BIOS=false
				fi
				done	
			fi		
		fi
	done	
		
	
	if [ $BIOS == true ]; then		
		echo "true";
	else
		echo "false";
	fi	
	
}