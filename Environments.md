
Use following configurations to be able to access certain epics networks:


* Environment - SwissFEL - _casf_

```matlab
properties = java.lang.Properties()
properties.setProperty('EPICS_CA_ADDR_LIST', 'sf-cagw')
properties.setProperty('EPICS_CA_SERVER_PORT', '5062')
```

* Environment - SwissFEL NS - _casfns_

```matlab
properties = java.lang.Properties()
properties.setProperty('EPICS_CA_ADDR_LIST', 'sf-cans-01 sf-cans-02')
properties.setProperty('EPICS_CA_SERVER_PORT', '5064')
```

* Environment - Hipa - _cahipa_

```matlab
properties = java.lang.Properties()
properties.setProperty('EPICS_CA_ADDR_LIST', 'hipa-cagw')
properties.setProperty('EPICS_CA_SERVER_PORT', '5062')
```

* Environment - OBLA - _caobla_

```matlab
properties = java.lang.Properties()
properties.setProperty('EPICS_CA_ADDR_LIST', 'trfcb-cagw')
properties.setProperty('EPICS_CA_SERVER_PORT', '5062')
```

* Environment - FIN - _cafin_

```matlab
properties = java.lang.Properties()
properties.setProperty('EPICS_CA_ADDR_LIST', 'fin-ccagw10w')
properties.setProperty('EPICS_CA_SERVER_PORT', '5062')
```

* Environment - Proscan - _capro_

```matlab
properties = java.lang.Properties()
properties.setProperty('EPICS_CA_ADDR_LIST', 'proscan-cagw01')
properties.setProperty('EPICS_CA_SERVER_PORT', '5062')
```

* Environment - SLS Machine - _cam_

```matlab
properties = java.lang.Properties()
properties.setProperty('EPICS_CA_ADDR_LIST', 'sls-cagw')
properties.setProperty('EPICS_CA_SERVER_PORT', '5062')
```

* Environment - Office - _cao_

```matlab
properties = java.lang.Properties()
properties.setProperty('EPICS_CA_ADDR_LIST', '129.129.130.255 129.129.131.255 129.129.137.255')
```

* Environment - SwissFEL SN - _casfsn_

```matlab
properties = java.lang.Properties()
properties.setProperty('EPICS_CA_ADDR_LIST', '172.26.0.255 172.26.8.255 172.26.16.255 172.26.24.255 172.26.32.255')
properties.setProperty('EPICS_CA_SERVER_PORT', '5064')
```
