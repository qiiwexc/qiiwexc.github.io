Function Set-PowerConfiguration {
    Add-Log $INF "Applying Windows power scheme settings..."

    powercfg /OverlaySetActive OVERLAY_SCHEME_MAX

    powercfg /SetAcValueIndex SCHEME_BALANCED 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 0
    powercfg /SetAcValueIndex SCHEME_BALANCED 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 1
    powercfg /SetAcValueIndex SCHEME_BALANCED 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
    powercfg /SetAcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 0
    powercfg /SetAcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 1
    powercfg /SetAcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 1
    powercfg /SetAcValueIndex SCHEME_BALANCED de830923-a562-41af-a086-e3a2c6bad2da e69653ca-cf7f-4f05-aa73-cb833fa90ad4 0
    powercfg /SetAcValueIndex SCHEME_BALANCED SUB_PCIEXPRESS ASPM 0
    powercfg /SetAcValueIndex SCHEME_BALANCED SUB_SLEEP HYBRIDSLEEP 1
    powercfg /SetAcValueIndex SCHEME_BALANCED SUB_SLEEP RTCWAKE 1

    powercfg /SetDcValueIndex SCHEME_BALANCED 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 0
    powercfg /SetDcValueIndex SCHEME_BALANCED 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 1
    powercfg /SetDcValueIndex SCHEME_BALANCED 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
    powercfg /SetDcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 0
    powercfg /SetDcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 1
    powercfg /SetDcValueIndex SCHEME_BALANCED 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 10778347-1370-4ee0-8bbd-33bdacaade49 1
    powercfg /SetDcValueIndex SCHEME_BALANCED de830923-a562-41af-a086-e3a2c6bad2da e69653ca-cf7f-4f05-aa73-cb833fa90ad4 0
    powercfg /SetDcValueIndex SCHEME_BALANCED SUB_PCIEXPRESS ASPM 0
    powercfg /SetDcValueIndex SCHEME_BALANCED SUB_SLEEP HYBRIDSLEEP 1
    powercfg /SetDcValueIndex SCHEME_BALANCED SUB_SLEEP RTCWAKE 1

    Out-Success
}
