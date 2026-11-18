<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
  xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer><Name>zonas_riesgo</Name><UserStyle><Title>Zonas de riesgo</Title><FeatureTypeStyle>
      <Rule><Title>Inundación · Alto</Title>
        <ogc:Filter><ogc:And>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>tipo</ogc:PropertyName><ogc:Literal>Inundación</ogc:Literal></ogc:PropertyIsEqualTo>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>nivel</ogc:PropertyName><ogc:Literal>Alto</ogc:Literal></ogc:PropertyIsEqualTo>
        </ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill><CssParameter name="fill">#1F5FAD</CssParameter><CssParameter name="fill-opacity">0.55</CssParameter></Fill>
          <Stroke><CssParameter name="stroke">#1F5FAD</CssParameter><CssParameter name="stroke-width">1</CssParameter></Stroke>
        </PolygonSymbolizer>
      </Rule>
      <Rule><Title>Inundación · Medio</Title>
        <ogc:Filter><ogc:And>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>tipo</ogc:PropertyName><ogc:Literal>Inundación</ogc:Literal></ogc:PropertyIsEqualTo>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>nivel</ogc:PropertyName><ogc:Literal>Medio</ogc:Literal></ogc:PropertyIsEqualTo>
        </ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill><CssParameter name="fill">#4A8FD9</CssParameter><CssParameter name="fill-opacity">0.45</CssParameter></Fill>
          <Stroke><CssParameter name="stroke">#4A8FD9</CssParameter><CssParameter name="stroke-width">1</CssParameter></Stroke>
        </PolygonSymbolizer>
      </Rule>
      <Rule><Title>Inundación · Bajo</Title>
        <ogc:Filter><ogc:And>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>tipo</ogc:PropertyName><ogc:Literal>Inundación</ogc:Literal></ogc:PropertyIsEqualTo>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>nivel</ogc:PropertyName><ogc:Literal>Bajo</ogc:Literal></ogc:PropertyIsEqualTo>
        </ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill><CssParameter name="fill">#9CC3EE</CssParameter><CssParameter name="fill-opacity">0.40</CssParameter></Fill>
          <Stroke><CssParameter name="stroke">#9CC3EE</CssParameter><CssParameter name="stroke-width">1</CssParameter></Stroke>
        </PolygonSymbolizer>
      </Rule>
      <Rule><Title>Remoción en masa · Alto</Title>
        <ogc:Filter><ogc:And>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>tipo</ogc:PropertyName><ogc:Literal>Remoción en masa</ogc:Literal></ogc:PropertyIsEqualTo>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>nivel</ogc:PropertyName><ogc:Literal>Alto</ogc:Literal></ogc:PropertyIsEqualTo>
        </ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill><CssParameter name="fill">#B5432A</CssParameter><CssParameter name="fill-opacity">0.55</CssParameter></Fill>
          <Stroke><CssParameter name="stroke">#B5432A</CssParameter><CssParameter name="stroke-width">1</CssParameter></Stroke>
        </PolygonSymbolizer>
      </Rule>
      <Rule><Title>Remoción en masa · Medio</Title>
        <ogc:Filter><ogc:And>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>tipo</ogc:PropertyName><ogc:Literal>Remoción en masa</ogc:Literal></ogc:PropertyIsEqualTo>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>nivel</ogc:PropertyName><ogc:Literal>Medio</ogc:Literal></ogc:PropertyIsEqualTo>
        </ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill><CssParameter name="fill">#D9814A</CssParameter><CssParameter name="fill-opacity">0.45</CssParameter></Fill>
          <Stroke><CssParameter name="stroke">#D9814A</CssParameter><CssParameter name="stroke-width">1</CssParameter></Stroke>
        </PolygonSymbolizer>
      </Rule>
      <Rule><Title>Remoción en masa · Bajo</Title>
        <ogc:Filter><ogc:And>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>tipo</ogc:PropertyName><ogc:Literal>Remoción en masa</ogc:Literal></ogc:PropertyIsEqualTo>
          <ogc:PropertyIsEqualTo><ogc:PropertyName>nivel</ogc:PropertyName><ogc:Literal>Bajo</ogc:Literal></ogc:PropertyIsEqualTo>
        </ogc:And></ogc:Filter>
        <PolygonSymbolizer>
          <Fill><CssParameter name="fill">#EDB98A</CssParameter><CssParameter name="fill-opacity">0.40</CssParameter></Fill>
          <Stroke><CssParameter name="stroke">#EDB98A</CssParameter><CssParameter name="stroke-width">1</CssParameter></Stroke>
        </PolygonSymbolizer>
      </Rule>
  </FeatureTypeStyle></UserStyle></NamedLayer>
</StyledLayerDescriptor>
