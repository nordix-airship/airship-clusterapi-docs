SUSHY_EMULATOR_LIBVIRT_URI = "qemu+ssh://root@192.168.111.1/system?&keyfile=/root/ssh/id_rsa_virt_power&no_verify=1&no_tty=1"
SUSHY_EMULATOR_IGNORE_BOOT_DEVICE = False
SUSHY_EMULATOR_VMEDIA_VERIFY_SSL = False
SUSHY_EMULATOR_AUTH_FILE = "/root/sushy/htpasswd"
SUSHY_EMULATOR_FAKE_DRIVER = True
SUSHY_EMULATOR_FAKE_IPA = True
FAKE_IPA_API_URL = "http://172.22.0.2:6385"
FAKE_IPA_INSPECTION_CALLBACK_URL = "http://172.22.0.2:5050/v1/continue"
FAKE_IPA_ADVERTISE_ADDRESS_IP = "192.168.111.1"
SUSHY_EMULATOR_FAKE_SYSTEMS = [
            {
                'uuid': '27946b59-9e44-4fa7-8e91-f3527a1ef094',
                'name': 'fake1',
                'power_state': 'Off',
                'fake_ipa': False,
                'nics': [
                    {
                        'mac': '00:5c:52:31:3a:9c',
                        'ip': '172.22.0.100'
                    }
                ]
            },
            {
                'uuid': '27946b59-9e44-4fa7-8e91-f3527a1ef095',
                'name': 'fake2',
                'power_state': 'Off',
                'fake_ipa': False,
                'nics': [
                    {
                        'mac': '00:5c:52:31:3a:9d',
                        'ip': '172.22.0.101'
                    }
                ]
            }
        ]