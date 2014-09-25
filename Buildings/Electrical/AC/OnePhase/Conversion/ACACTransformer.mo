within Buildings.Electrical.AC.OnePhase.Conversion;
model ACACTransformer "AC AC transformer simplified equivalent circuit"
  extends Buildings.Electrical.Interfaces.PartialConversion(
    redeclare package PhaseSystem_p = PhaseSystems.OnePhase,
    redeclare package PhaseSystem_n = PhaseSystems.OnePhase,
    redeclare Interfaces.Terminal_n terminal_n(
      redeclare package PhaseSystem = PhaseSystem_n,
      i(start = zeros(PhaseSystem_n.n),
      each stateSelect = StateSelect.prefer)),
    redeclare Interfaces.Terminal_p terminal_p(
      redeclare package PhaseSystem = PhaseSystem_p,
      i(start = zeros(PhaseSystem_p.n),
      each stateSelect = StateSelect.prefer)));
  parameter Modelica.SIunits.Voltage VHigh
    "Rms voltage on side 1 of the transformer (primary side)";
  parameter Modelica.SIunits.Voltage VLow
    "Rms voltage on side 2 of the transformer (secondary side)";
  parameter Modelica.SIunits.ApparentPower VABase
    "Nominal power of the transformer";
  parameter Real XoverR
    "Ratio between the complex and real components of the impedance (XL/R)";
  parameter Real Zperc "Short circuit impedance";
  parameter Boolean ground_1 = false
    "If true, connect side 1 of converter to ground"
    annotation(Evaluate=true,Dialog(tab = "Ground", group="side 1"));
  parameter Boolean ground_2 = true
    "If true, connect side 2 of converter to ground"
    annotation(Evaluate=true, Dialog(tab = "Ground", group="side 2"));
  parameter Modelica.SIunits.Angle phi_1 = 0
    "Angle of the voltage side 1 at initialization"
     annotation(Evaluate=true,Dialog(tab = "Initialization"));
  parameter Modelica.SIunits.Angle phi_2 = phi_1
    "Angle of the voltage side 2 at initialization"
     annotation(Evaluate=true, Dialog(tab = "Initialization"));
  Modelica.SIunits.Efficiency eta "Efficiency";
  Modelica.SIunits.Power LossPower[2] "Loss power";
protected
  Real N = VHigh/VLow "Winding ratio";
  Modelica.SIunits.Current IHigh = VABase/VHigh
    "Nominal current on primary side";
  Modelica.SIunits.Current ILow = VABase/VLow
    "Nominal current on secondary side";
  Modelica.SIunits.Current IscHigh = IHigh/Zperc
    "Short circuit current on primary side";
  Modelica.SIunits.Current IscLow = ILow/Zperc
    "Short circuit current on secondary side";
  Modelica.SIunits.Impedance Zp = VHigh/IscHigh
    "Impedance of the primary side (module)";
  Modelica.SIunits.Impedance Z1[2] = {Zp*cos(atan(XoverR)), Zp*sin(atan(XoverR))}
    "Impedance of the primary side of the transformer";
  Modelica.SIunits.Impedance Zs = VLow/IscLow
    "Impedance of the secondary side (module)";
  Modelica.SIunits.Impedance Z2[2] = {Zs*cos(atan(XoverR)), Zs*sin(atan(XoverR))}
    "Impedance of the secondary side of the transformer";
  Modelica.SIunits.Voltage V1[2](start = PhaseSystem_n.phaseVoltages(VHigh, phi_1))
    "Voltage at the winding - primary side";
  Modelica.SIunits.Voltage V2[2](start = PhaseSystem_p.phaseVoltages(VLow, phi_2))
    "Voltage at the winding - secondary side";
  Modelica.SIunits.Power P_p[2] = PhaseSystem_p.phasePowers_vi(terminal_p.v, terminal_p.i)
    "Power transmitted at pin p (secondary)";
  Modelica.SIunits.Power P_n[2] = PhaseSystem_n.phasePowers_vi(terminal_n.v, terminal_n.i)
    "Power transmitted at pin n (primary)";
  Modelica.SIunits.Power Sp = sqrt(P_p[1]^2 + P_p[2]^2)
    "Apparent power terminal p";
  Modelica.SIunits.Power Sn = sqrt(P_n[1]^2 + P_n[2]^2)
    "Apparent power terminal n";

equation
  // Efficiency
  eta = Buildings.Utilities.Math.Functions.smoothMin(
        x1=  sqrt(P_p[1]^2 + P_p[2]^2) / (sqrt(P_n[1]^2 + P_n[2]^2) + 1e-6),
        x2=  sqrt(P_n[1]^2 + P_n[2]^2) / (sqrt(P_p[1]^2 + P_p[2]^2) + 1e-6),
        deltaX=  0.01);

  // Ideal transformation
  V2 = V1/N;
  terminal_p.i[1] + terminal_n.i[1]*N = 0;
  terminal_p.i[2] + terminal_n.i[2]*N = 0;

  // Losses due to the impedance
  terminal_n.v = V1 + Buildings.Electrical.PhaseSystems.OnePhase.product(
    terminal_n.i, Z1);
  V2 = terminal_p.v;

  // Loss of power
  LossPower = P_p + P_n;

  // The two sides have the same reference angle
  terminal_p.theta = terminal_n.theta;

  if ground_1 then
    Connections.potentialRoot(terminal_n.theta);
  end if;
  if ground_2 then
    Connections.root(terminal_p.theta);
  end if;

  annotation (
  defaultComponentName="traACAC",
  Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,
            -100},{100,100}}),
                      graphics), Icon(coordinateSystem(preserveAspectRatio=false,
          extent={{-100,-100},{100,100}}),
                                      graphics={
        Text(
          extent={{-100,-60},{100,-92}},
          lineColor={0,120,120},
          textString="%name"),
        Text(
          extent={{-130,60},{-70,20}},
          lineColor={11,193,87},
          textString="1"),
        Text(
          extent={{-130,100},{-70,60}},
          lineColor={11,193,87},
          textString="AC"),
        Text(
          extent={{70,100},{130,60}},
          lineColor={0,120,120},
          textString="AC"),
        Text(
          extent={{70,60},{130,20}},
          lineColor={0,120,120},
          textString="2"),
        Line(visible = ground_1 == true,
          points={{-80,-40},{-120,-40}},
          color={0,120,120},
          smooth=Smooth.None,
          thickness=0.5),
        Line(visible = ground_1 == true,
          points={{-80,-40},{-106,-14}},
          color={0,120,120},
          smooth=Smooth.None,
          thickness=0.5),
        Line(visible = ground_1 == true,
          points={{-102,-16},{-114,-24},{-118,-42}},
          color={0,120,120},
          smooth=Smooth.Bezier),
        Line(visible = ground_2 == true,
          points={{80,-40},{120,-40}},
          color={0,120,120},
          smooth=Smooth.None,
          thickness=0.5),
        Line(visible = ground_2 == true,
          points={{80,-40},{106,-14}},
          color={0,120,120},
          smooth=Smooth.None,
          thickness=0.5),
        Line(visible = ground_2 == true,
          points={{102,-16},{114,-24},{118,-42}},
          color={0,120,120},
          smooth=Smooth.Bezier),
        Line(
          points={{-72,40},{-66,40},{-64,44},{-60,36},{-56,44},{-52,36},{-48,44},
              {-44,36},{-42,40},{-38,40}},
          color={0,127,127},
          smooth=Smooth.None),
          Line(
          points={{-6.85214e-44,-8.39117e-60},{-60,-7.34764e-15}},
          color={0,127,127},
          origin={-40,40},
          rotation=180),
        Ellipse(
          extent={{-30,46},{-18,34}},
          lineColor={0,127,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-18,46},{-6,34}},
          lineColor={0,127,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-6,46},{6,34}},
          lineColor={0,127,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-30,40},{6,28}},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Line(
          points={{20,40},{20,20}},
          color={0,127,127},
          smooth=Smooth.None),
        Ellipse(
          extent={{14,20},{26,8}},
          lineColor={0,127,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{14,8},{26,-4}},
          lineColor={0,127,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{14,-4},{26,-16}},
          lineColor={0,127,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{10,20},{20,-16}},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Line(
          points={{20,-16},{20,-40}},
          color={0,127,127},
          smooth=Smooth.None),
        Line(
          points={{20,-40},{-70,-40}},
          color={0,127,127},
          smooth=Smooth.None),
        Line(
          points={{34,40},{34,20}},
          color={0,127,127},
          smooth=Smooth.None),
        Ellipse(
          extent={{40,20},{28,8}},
          lineColor={0,127,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{40,8},{28,-4}},
          lineColor={0,127,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{40,-4},{28,-16}},
          lineColor={0,127,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{44,20},{34,-16}},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          pattern=LinePattern.None),
        Line(
          points={{34,-16},{34,-40}},
          color={0,127,127},
          smooth=Smooth.None),
        Line(
          points={{70,-40},{34,-40}},
          color={0,127,127},
          smooth=Smooth.None),
        Line(
          points={{70,40},{34,40}},
          color={0,127,127},
          smooth=Smooth.None),
        Text(
          extent={{-64,60},{-48,48}},
          lineColor={0,120,120},
          textString="R"),
        Text(
          extent={{-20,60},{-4,48}},
          lineColor={0,120,120},
          textString="L")}),
    Documentation(info="<html>
<p>
This is a simplified equivalent transformer model.
The model accounts for winding joule losses and leakage reactances 
that are represented by a serie of a resistance <i>R</i> and an
inductance <i>L</i>. The resistance and the inductance represent both the 
effects of the secondary and primary side of the transformer.
</p>
<p>
The model is parametrized using the following parameters
</p>
<ul>
<li><code>VHigh</code> - RMS voltage at primary side,</li>
<li><code>VLow</code> - RMS voltage at secondary side,</li>
<li><code>VABase</code> - apparent nominal power of the transformer,</li>
<li><code>XoverR</code> - ratio between reactance and resistance, and</li>
<li><code>Zperc</code> - the short circuit impedance.</li>
</ul>
<p>
Given the nominal conditions,the model computes the values of the resistance and the inductance.
</p>
</html>", revisions="<html>
<ul>
<li>
September 4, 2014, by Michael Wetter:<br/>
Revised model.
</li>
<li>
August 5, 2014, by Marco Bonvini:<br/>
Revised documentation.
</li>
<li>June 17, 2014, by Marco Bonvini:<br/>
Adde parameter <code>phi_1</code> and <code>phi_2</code> that are
used during initialization to specify the angle of the voltage phasor.
</li>
<li>
June 9, 2014, by Marco Bonvini:<br/>
Revised implementation and added <code>stateSelect</code> statement to use
the current <code>i[:]</code> on the connectors as iteration variable for the
initialization problem.
</li>
<li>
January 29, 2012, by Thierry S. Nouidui:<br/>
First implementation.
</li>
</ul>
</html>"));
end ACACTransformer;
