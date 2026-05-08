# GPO Setup

## GPO 1: Windows 7

Name:

```text
Deploy RustDesk - Windows 7 Legacy
```

Startup Script:

```text
\\YOUR-FILE-SERVER\YOUR-SHARE$\win7\install\rustdesk-win7-deploy.cmd
```

WMI filter:

```text
Windows 7 Workstations
```

## GPO 2: Windows 10/11

Name:

```text
Deploy RustDesk - Windows 10-11
```

Startup Script:

```text
\\YOUR-FILE-SERVER\YOUR-SHARE$\win10-11\install\rustdesk-win10-11-deploy.cmd
```

WMI filter:

```text
Windows 10 and 11 Workstations
```

## Security Filtering

Simplified production option:

```text
Domain Computers
```

Controlled rollout option:

```text
GG_RustDesk_Win7_Deploy
GG_RustDesk_Win10_11_Deploy
```

## Delegation

Если используешь deploy-группы вместо `Domain Computers`, оставь:

```text
Authenticated Users: Read
Deploy group: Read + Apply group policy
```

## Network wait policy

Enable:

```text
Computer Configuration
→ Policies
→ Administrative Templates
→ System
→ Logon
→ Always wait for the network at computer startup and logon
```

## Enforced

Для RustDesk GPO обычно не включать:

```text
Enforced: No
```
