Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$brandDir = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../assets/brand'))
$fonts = New-Object System.Drawing.Text.PrivateFontCollection
$fonts.AddFontFile((Join-Path $brandDir 'fonts/SongMyung-Regular.ttf'))
$culture = [Globalization.CultureInfo]::InvariantCulture
function Num($v) { ([double]$v).ToString('0.###', $culture) }
function Color($hex) { [Drawing.ColorTranslator]::FromHtml($hex) }
function PathData($path) {
  $parts = [Collections.Generic.List[string]]::new()
  $points = $path.PathPoints; $types = $path.PathTypes
  for ($i = 0; $i -lt $points.Length; $i++) {
    $kind = $types[$i] -band 7
    if ($kind -eq 0) { $parts.Add("M$(Num $points[$i].X) $(Num $points[$i].Y)") }
    elseif ($kind -eq 1) { $parts.Add("L$(Num $points[$i].X) $(Num $points[$i].Y)") }
    elseif ($kind -eq 3) {
      $parts.Add("C$(Num $points[$i].X) $(Num $points[$i].Y) $(Num $points[$i+1].X) $(Num $points[$i+1].Y) $(Num $points[$i+2].X) $(Num $points[$i+2].Y)")
      $i += 2
    }
    if (($types[$i] -band 128) -ne 0) { $parts.Add('Z') }
  }
  return $parts -join ' '
}
function StartAsset($width, $height, $background, $title) {
  $script:bitmap = New-Object Drawing.Bitmap($width, $height)
  $script:g = [Drawing.Graphics]::FromImage($bitmap)
  $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $script:svg = [Collections.Generic.List[string]]::new()
  $svg.Add("<svg xmlns=`"http://www.w3.org/2000/svg`" width=`"$width`" height=`"$height`" viewBox=`"0 0 $width $height`" role=`"img`" aria-labelledby=`"title`"><title id=`"title`">$title</title>")
  if ($background) {
    $g.Clear((Color $background))
    $svg.Add("<rect width=`"$width`" height=`"$height`" fill=`"$background`"/>")
  } else { $g.Clear([Drawing.Color]::Transparent) }
}
function DrawPath($path, $fill, $stroke, $weight = 1) {
  $data = PathData $path
  if ($fill) {
    $brush = New-Object Drawing.SolidBrush((Color $fill))
    $g.FillPath($brush, $path); $brush.Dispose()
    $svg.Add("<path d=`"$data`" fill=`"$fill`" fill-rule=`"evenodd`"/>")
  } else {
    $pen = New-Object Drawing.Pen((Color $stroke)), $weight
    $pen.StartCap = $pen.EndCap = [Drawing.Drawing2D.LineCap]::Round
    $pen.LineJoin = [Drawing.Drawing2D.LineJoin]::Round
    $g.DrawPath($pen, $path); $pen.Dispose()
    $svg.Add("<path d=`"$data`" fill=`"none`" stroke=`"$stroke`" stroke-width=`"$weight`" stroke-linecap=`"round`" stroke-linejoin=`"round`"/>")
  }
  $path.Dispose()
}
function Mark($x, $y, $scale, $color) {
  $path = New-Object Drawing.Drawing2D.GraphicsPath
  $path.AddEllipse(138, 14, 24, 24)
  $path.AddRectangle([Drawing.RectangleF]::new(138, 38, 24, 18))
  $path.AddRectangle([Drawing.RectangleF]::new(128, 56, 44, 26))
  $path.AddEllipse(32, 82, 236, 236)
  foreach ($line in @(@(92,220,92,160),@(110,220,110,140),@(128,224,128,165),@(150,226,150,150),@(172,224,172,158),@(190,220,190,172))) {
    $path.StartFigure(); $path.AddLine($line[0],$line[1],$line[2],$line[3])
  }
  $path.StartFigure(); $path.AddArc(85,192,130,80,180,180)
  $matrix = New-Object Drawing.Drawing2D.Matrix($scale,0,0,$scale,$x,$y)
  $path.Transform($matrix); $matrix.Dispose()
  DrawPath $path $null $color (3.2 * $scale)
}
function Lettering($text, $x, $y, $size, $color) {
  $path = New-Object Drawing.Drawing2D.GraphicsPath
  $path.AddString($text, $fonts.Families[0], 0, $size, [Drawing.PointF]::new($x,$y), [Drawing.StringFormat]::GenericTypographic)
  DrawPath $path $color $null
}
function Dots($x,$y,$radius,$gap) {
  $colors = @('#7FA0C0','#D9BE72','#4A4844','#9AAB90','#BE9089')
  for ($i=0; $i -lt 5; $i++) {
    $path = New-Object Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse([single]($x+$i*$gap),[single]$y,[single]($radius*2),[single]($radius*2))
    DrawPath $path $colors[$i] $null
  }
}
function SaveAsset($name) {
  $svg.Add('</svg>')
  [IO.File]::WriteAllText((Join-Path $brandDir "$name.svg"), ($svg -join "`n"), [Text.UTF8Encoding]::new($false))
  $bitmap.Save((Join-Path $brandDir "$name.png"), [Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bitmap.Dispose()
}

foreach ($variant in @(
  @{Name='dabar-logo-dark'; Background='#211F1B'; Text='#EDE8DC'; Gold='#D9BE72'},
  @{Name='dabar-logo-light'; Background='#EDE8DC'; Text='#211F1B'; Gold='#947C3E'},
  @{Name='dabar-logo-transparent'; Background=$null; Text='#211F1B'; Gold='#947C3E'}
)) {
  StartAsset 900 400 $variant.Background '다바르 DABAR — 유리병과 여명의 갈대 로고'
  Mark 58 25 1.05 $variant.Gold
  Lettering '다바르' 421 55 146 $variant.Text
  Lettering 'D A B A R' 432 220 32 $variant.Gold
  Dots 436 306 7 42
  SaveAsset $variant.Name
}
StartAsset 1024 1024 '#211F1B' '다바르 프로필 심볼'
Mark 107 52 2.7 '#D9BE72'
Dots 360 946 8 72
SaveAsset 'dabar-icon'
StartAsset 512 512 $null '다바르 금빛 유리병 심볼'
Mark 46 16 1.4 '#D9BE72'
SaveAsset 'dabar-symbol-gold'
$fonts.Dispose()
Write-Output "Created 5 SVG and 5 PNG assets in $brandDir"
