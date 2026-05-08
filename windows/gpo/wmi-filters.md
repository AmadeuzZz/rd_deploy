# WMI Filters

## Windows 7 Workstations

Namespace:

```text
root\CIMv2
```

Query:

```sql
SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "6.1%" AND ProductType = "1"
```

## Windows 10 and 11 Workstations

Namespace:

```text
root\CIMv2
```

Query:

```sql
SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.%" AND ProductType = "1"
```

Windows 11 также имеет major version `10.0`, поэтому фильтр `10.%` покрывает Win10 и Win11.
