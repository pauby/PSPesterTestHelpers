---
external help file: pspestertesthelpers-help.xml
Module Name: pspestertesthelpers
online version:
schema: 2.0.0
---

# Assert-PTHMandatoryParameter

## SYNOPSIS
Asserts that a function has only the mandatory parameters we pass.

## SYNTAX

```
Assert-PTHMandatoryParameter [-FunctionName] <String> [-ParameterName] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Asserts that a function has only the mandatory parameters we pass.
Returns true if it does and false otherwise.

## EXAMPLES

### EXAMPLE 1
```
Assert-MandatoryParameter -FunctionName 'Get-MyFunction' -ParameterName 'Name'
```

Asserts that the function 'Get-MyFunction' has only one mandatory parameter called 'Name'.

## PARAMETERS

### -FunctionName
{{Fill FunctionName Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParameterName
{{Fill ParameterName Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean
## NOTES
Author : Paul Broadwith https://github.com/pauby
History: 2019-01-09 - pauby - Initial release

## RELATED LINKS
