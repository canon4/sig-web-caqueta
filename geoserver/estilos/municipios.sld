<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor version="1.0.0"
  xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer><Name>municipios</Name><UserStyle><Title>Municipios</Title>
    <FeatureTypeStyle><Rule><Title>Municipio</Title>
      <PolygonSymbolizer>
        <Fill><CssParameter name="fill">#E8F1E4</CssParameter><CssParameter name="fill-opacity">0.45</CssParameter></Fill>
        <Stroke><CssParameter name="stroke">#3D6B35</CssParameter><CssParameter name="stroke-width">1.2</CssParameter></Stroke>
      </PolygonSymbolizer>
      <TextSymbolizer>
        <Label><ogc:PropertyName>nombre</ogc:PropertyName></Label>
        <Font><CssParameter name="font-family">SansSerif</CssParameter><CssParameter name="font-size">11</CssParameter><CssParameter name="font-weight">bold</CssParameter></Font>
        <LabelPlacement><PointPlacement><AnchorPoint><AnchorPointX>0.5</AnchorPointX><AnchorPointY>0.5</AnchorPointY></AnchorPoint></PointPlacement></LabelPlacement>
        <Halo><Radius>1.5</Radius><Fill><CssParameter name="fill">#FFFFFF</CssParameter></Fill></Halo>
        <Fill><CssParameter name="fill">#24421F</CssParameter></Fill>
        <VendorOption name="autoWrap">90</VendorOption>
        <VendorOption name="maxDisplacement">40</VendorOption>
      </TextSymbolizer>
    </Rule></FeatureTypeStyle>
  </UserStyle></NamedLayer>
</StyledLayerDescriptor>
