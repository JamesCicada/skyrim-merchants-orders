Scriptname SKI_ConfigBase extends Quest
String Property ModName Auto
Event OnConfigInit()
EndEvent
Event OnPageReset(String asPage)
EndEvent
Event OnOptionSliderOpen(Int aiOption)
EndEvent
Event OnOptionSliderAccept(Int aiOption, Float afValue)
EndEvent
Event OnOptionHighlight(Int aiOption)
EndEvent
Int Function AddHeaderOption(String a_text, Int a_flags = 0)
    Return 0
EndFunction
Int Function AddTextOption(String a_text, String a_value, Int a_flags = 0)
    Return 0
EndFunction
Int Function AddSliderOption(String a_text, Float a_value, String a_formatString = "{0}", Int a_flags = 0)
    Return 0
EndFunction
Function SetSliderDialogStartValue(Float a_value)
EndFunction
Function SetSliderDialogDefaultValue(Float a_value)
EndFunction
Function SetSliderDialogRange(Float a_minValue, Float a_maxValue)
EndFunction
Function SetSliderDialogInterval(Float a_value)
EndFunction
Function SetSliderOptionValue(Int a_option, Float a_value, String a_formatString = "{0}", Bool a_noUpdate = False)
EndFunction
Function SetInfoText(String a_text)
EndFunction
