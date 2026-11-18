<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
  xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer><Name>vias</Name><UserStyle><Title>Vías</Title><FeatureTypeStyle>
    <Rule><Title>Primaria</Title>
      <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>tipo</ogc:PropertyName><ogc:Literal>Primaria</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
      <LineSymbolizer><Stroke><CssParameter name="stroke">#5A3A1A</CssParameter><CssParameter name="stroke-width">4.5</CssParameter><CssParameter name="stroke-linecap">round</CssParameter></Stroke></LineSymbolizer>
      <LineSymbolizer><Stroke><CssParameter name="stroke">#F2B33D</CssParameter><CssParameter name="stroke-width">2.5</CssParameter><CssParameter name="stroke-linecap">round</CssParameter></Stroke></LineSymbolizer>
    </Rule>
    <Rule><Title>Secundaria</Title>
      <ogc:Filter><ogc:PropertyIsEqualTo><ogc:PropertyName>tipo</ogc:PropertyName><ogc:Literal>Secundaria</ogc:Literal></ogc:PropertyIsEqualTo></ogc:Filter>
      <LineSymbolizer><Stroke><CssParameter name="stroke">#7A5C3A</CssParameter><CssParameter name="stroke-width">2</CssParameter><CssParameter name="stroke-dasharray">6 3</CssParameter></Stroke></LineSymbolizer>
    </Rule>
  </FeatureTypeStyle></UserStyle></NamedLayer>
</StyledLayerDescriptor>
