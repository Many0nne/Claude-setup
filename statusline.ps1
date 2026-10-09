# Sortie en UTF-8 sans BOM, sinon les emoji sortent en "?" avec la page de code OEM de Windows.
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$raw = [Console]::In.ReadToEnd()
try { $j = $raw | ConvertFrom-Json } catch { $j = $null }

$esc = [char]27
$reset = "$esc[0m"
$dim = "$esc[90m"

# Icones construites via code point pour ne pas dependre de l'encodage du fichier.
$iconCtx = [char]::ConvertFromUtf32(0x1F9E0)   # cerveau : contexte
$iconSess = [char]::ConvertFromUtf32(0x23F3)   # sablier : session
$iconWater = [char]::ConvertFromUtf32(0x1F4A7) # goutte : eau
$iconCo2 = [char]::ConvertFromUtf32(0x1F33F)   # feuille : CO2

# Facteurs de conversion par dollar depense (hypotheses grossieres, a ajuster).
# 1 USD ~ 0.25 kWh d'inference ; reseau ~ 0.4 kg CO2/kWh ; eau ~ 2 L/kWh (refroidissement + production electrique).
$KWH_PER_USD = 0.25
$G_CO2_PER_KWH = 400
$L_WATER_PER_KWH = 2

# Cette methode permet de formater un pourcentage en couleur lorsque la valeur est disponible, sinon "--".
function Format-Pct($label, $value) {
    if ($null -eq $value) { return "$dim$label$reset --" }
    $p = [math]::Round([double]$value)
    $color = if ($p -ge 80) { 31 } elseif ($p -ge 50) { 33 } else { 32 }
    return "$dim$label$reset $esc[${color}m$p%$reset"
}

# Cette methode permet de formater une quantite d'eau en mL ou L lorsque le cout de session est connu.
function Format-Water($usd) {
    $l = $usd * $KWH_PER_USD * $L_WATER_PER_KWH
    if ($l -lt 1) { return ('{0} mL' -f [math]::Round($l * 1000)) }
    return ('{0:N1} L' -f $l)
}

# Cette methode permet de formater une masse de CO2 en g ou kg lorsque le cout de session est connu.
function Format-Co2($usd) {
    $g = $usd * $KWH_PER_USD * $G_CO2_PER_KWH
    if ($g -lt 1000) { return ('{0} g' -f [math]::Round($g)) }
    return ('{0:N2} kg' -f ($g / 1000))
}

$ctx = $null
$sess = $null
$usd = $null
if ($j) {
    if ($j.context_window) { $ctx = $j.context_window.used_percentage }
    if ($j.rate_limits -and $j.rate_limits.five_hour) { $sess = $j.rate_limits.five_hour.used_percentage }
    if ($j.cost -and $null -ne $j.cost.total_cost_usd) { $usd = [double]$j.cost.total_cost_usd }
}

$sep = " $dim|$reset "
$parts = @((Format-Pct "$iconCtx ctx" $ctx), (Format-Pct "$iconSess session" $sess))
if ($null -ne $usd) {
    $parts += ('{0} ~{1}' -f $iconWater, (Format-Water $usd))
    $parts += ('{0} CO2 ~{1}' -f $iconCo2, (Format-Co2 $usd))
}

[Console]::Out.Write($parts -join $sep)
