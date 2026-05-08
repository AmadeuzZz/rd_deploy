Randomize

chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$_.+="
pass = ""

For i = 1 To 12
    pass = pass & Mid(chars, Int(Rnd() * Len(chars)) + 1, 1)
Next

WScript.Echo pass
