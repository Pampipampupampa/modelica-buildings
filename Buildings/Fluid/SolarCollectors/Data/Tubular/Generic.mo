within Buildings.Fluid.SolarCollectors.Data.Tubular;
record Generic "SRCC rating information for tubular collectors"
  extends Modelica.Icons.Record;
  parameter SolarCollectors.Types.Area ATyp "Gross or aperture area";
  parameter SolarCollectors.Types.DesignFluid Fluid
    "Specifies the fluid the heater is designed to use";
  parameter Modelica.SIunits.Area A "Area";
  parameter Modelica.SIunits.Mass mDry "Dry weight";
  parameter Modelica.SIunits.Volume V "Fluid volume";
  parameter Modelica.SIunits.Pressure dp_nominal "Pressure drop during test";
  parameter Real VperA_flow_nominal(unit="m/s")
    "Volume flow rate per area of test flow";
  parameter Real B0 "1st incident angle modifier coefficient";
  parameter Real B1 "2nd incident angle modifer coefficient";
  parameter Real y_intercept "Y intercept (Maximum efficiency)";
  parameter Real slope(unit = "W/(m2.K)") "Slope from rating data";
  parameter Real IAMDiff "Incidence angle modifier from EN12975 ratings data";
  parameter Real C1 "Heat loss coefficient from EN12974 ratings data";
  parameter Real C2
    "Temperature dependence of heat loss from EN12975 ratings data";
  annotation (defaultComponentName="gas", Documentation(info="<html>
Generic record for solar information from SRCC certified solar collectors. This generic record is intended for tubular collectors using data collected according to ASHRAE93.
The implementation is according to 
<a href=\"http://www.solar-rating.org/ratings/og100.html\">SRCC OG-100 Directory, 
SRCC Certified Solar Collecotr Ratings</a>.
</html>", revisions="<html>
<ul>
<li>
Feb 28, 2013, by Peter Grant:<br>
First implementation.
</li>
</ul>
</html>"));
end Generic;