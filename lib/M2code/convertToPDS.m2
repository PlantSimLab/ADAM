--load "GSTOPDS.m2"

newPackage(
     "convertToPDS",
     Version => "1.0",
     Date => "July 22, 2010",
     Authors => {
         {Name => "Bonny Guang, Madison Brandon, Rustin McNeill, Franziska
             Hinkelmann, Alan Veliz-Cuba" }},
     Headline => "Converts a Logical Model from GINSim to a PDS",
     PackageExports => {"GSTOPDS"}
     )

--needsPackage "GSTOPDS"
export {converter}
exportMutable {}
     
converter = method()
converter String := Sequence => gfile -> (
     --uses alans code to make PDS from a GINsim file
     (polySystem,R) := fromGStoPDS gfile;
     F := matrix(R, { polySystem});
     -- prints list of genes and variables
     geneList := getListOfGenes gfile;
     (geneList, F)
)

beginDocumentation();

doc ///
  Key
    (converter,String)
    converter
  Headline
    Converts Logical Models from GINsim file to PDS
  Usage
    converter test.ginml
  Inputs
    gfile:String
      A ginml file
  Outputs
    L:Sequence
      A list of genes/proteins, and a matrix with all polynomials that correspond to the GINsim model
  Description
    Text
      converter converts a Logical Model into a PDS. It is using the method
      desribed in {\tt Polynomial Algebra of Discrete Models in Systems
      Biology
      Alan Veliz-Cuba, Abdul Salam Jarrah, and Reinhard Laubenbacher,
      Bioinformatics Advance Access published May 6, 2010}.
  Caveat
    The input file must be from GINSim in version 2.3, and not in extended (zipped) format (i.e., ".ginml" is ok, ".zginml" does not work for the converter).  converter does not work for the newer version. To convert a file made with GINSim version 2.4 or newer, open with GINSim version 2.3 and save as not "Extended Save". This converts the file to the correct format the converter can parse.  
  SeeAlso
    "solvebyGB"
///


TEST ///

-- first make a string with the content of a file, then get a temporary file name
-- write the string to the temporary file, then use converter on the temporary file
s := ////<?xml version="1.0" encoding="UTF-8"?>i
<!DOCTYPE gxl SYSTEM "file://fr/univmrs/ibdm/GINsim/ressources/GINML_2_1.dtd">
<gxl xmlns:xlink="http://www.w3.org/1999/xlink">
	<graph id="default_name" class="regulatory" nodeorder="LIP Fpn TfR1 Ft IRP">
<node id="Ft" basevalue="1" maxvalue="2">
  <parameter idActiveInteractions="LIP_Ft_0 IRP_Ft_0" val="1"/>

			<nodevisualsetting>
				<rect x="621" y="219" width="55" height="25" backgroundColor="#FF9900" foregroundColor="#FFFFFF"/>
			</nodevisualsetting>
</node>
<node id="Fpn" basevalue="1" maxvalue="2">
  <parameter idActiveInteractions="IRP_Fpn_0" val="1"/>

			<nodevisualsetting>
				<rect x="756" y="127" width="55" height="25" backgroundColor="#FF9900" foregroundColor="#FFFFFF"/>
			</nodevisualsetting>
</node>
<node id="IRP" basevalue="1" maxvalue="2">
  <parameter idActiveInteractions="LIP_IRP_0" val="1"/>

			<nodevisualsetting>
				<rect x="769" y="347" width="55" height="25" backgroundColor="#FF9900" foregroundColor="#FFFFFF"/>
			</nodevisualsetting>
</node>
<node id="TfR1" basevalue="1" maxvalue="2">
  <parameter idActiveInteractions="IRP_TfR1_0" val="1"/>

			<nodevisualsetting>
				<rect x="469" y="216" width="55" height="23" backgroundColor="#FF9900" foregroundColor="#FFFFFF"/>
			</nodevisualsetting>
</node>
<node id="LIP" basevalue="1" maxvalue="2">
  <parameter idActiveInteractions="TfR1_LIP_0 Fpn_LIP_0" val="1"/>
  <parameter idActiveInteractions="TfR1_LIP_0 Ft_LIP_0" val="1"/>
  <parameter idActiveInteractions="TfR1_LIP_0 Fpn_LIP_0 Ft_LIP_0" val="1"/>
  <parameter idActiveInteractions="Ft_LIP_1" val="1"/>

			<nodevisualsetting>
				<rect x="587" y="92" width="55" height="25" backgroundColor="#FF9900" foregroundColor="#FFFFFF"/>
			</nodevisualsetting>
</node>
		<edge id="Ft_LIP_0" from="Ft" to="LIP" minvalue="1" maxvalue="1" sign="negative">
			<edgevisualsetting>
				<polyline points="648,231 645,164 614,104" line_style="curve" line_color="#3399FF" line_width="2" routage="auto"/>
			</edgevisualsetting>
		</edge>
		<edge id="Ft_LIP_1" from="Ft" to="LIP" minvalue="2" sign="positive">
			<edgevisualsetting>
				<polyline points="648,231 645,164 614,104" line_style="curve" line_color="#3399FF" line_width="2" routage="auto"/>
			</edgevisualsetting>
		</edge>
		<edge id="Fpn_LIP_0" from="Fpn" to="LIP" minvalue="1" sign="negative">
			<edgevisualsetting>
				<polyline points="783,139 614,104" line_style="curve" line_color="#3399FF" line_width="2" routage="manual"/>
			</edgevisualsetting>
		</edge>
		<edge id="IRP_TfR1_0" from="IRP" to="TfR1" minvalue="1" sign="positive">
			<edgevisualsetting>
				<polyline points="796,359 496,227" line_style="curve" line_color="#3399FF" line_width="2" routage="manual"/>
			</edgevisualsetting>
		</edge>
		<edge id="IRP_Fpn_0" from="IRP" to="Fpn" minvalue="1" sign="negative">
			<edgevisualsetting>
				<polyline points="796,359 783,139" line_style="curve" line_color="#3399FF" line_width="2" routage="manual"/>
			</edgevisualsetting>
		</edge>
		<edge id="IRP_Ft_0" from="IRP" to="Ft" minvalue="1" sign="negative">
			<edgevisualsetting>
				<polyline points="796,359 648,231" line_style="curve" line_color="#3399FF" line_width="2" routage="manual"/>
			</edgevisualsetting>
		</edge>
		<edge id="TfR1_LIP_0" from="TfR1" to="LIP" minvalue="1" sign="positive">
			<edgevisualsetting>
				<polyline points="496,227 614,104" line_style="curve" line_color="#3399FF" line_width="2" routage="manual"/>
			</edgevisualsetting>
		</edge>
		<edge id="LIP_Ft_0" from="LIP" to="Ft" minvalue="1" sign="positive">
			<edgevisualsetting>
				<polyline points="614,104 617,171 648,231" line_style="curve" line_color="#3399FF" line_width="2" routage="auto"/>
			</edgevisualsetting>
		</edge>
		<edge id="LIP_IRP_0" from="LIP" to="IRP" minvalue="1" sign="negative">
			<edgevisualsetting>
				<polyline points="614,104 796,359" line_style="curve" line_color="#3399FF" line_width="2" routage="manual"/>
			</edgevisualsetting>
		</edge>
	</graph>
</gxl> //// 

f := temporaryFileName() | ".ginml";
g := openOut f;
g << s;
close g;
assert( toString converter(f) == toString ({"LIP", "Fpn", "TfR1", "Ft", "IRP"},matrix {{x2^2*x3^2*x4-x2^2*x3^2-x2^2*x4^2+x3^2*x4^2-x2^2*x4+x3^2*x4-x2^2-x3^2+x4^2+x4+1, 1, 1, -x1^2*x5^2-x1^2-x5^2+1, 1}}))

///

end 

restart

converter("GinSimFiles/logicalmodel1.ginml")

restart
installPackage "convertToPDS"
viewHelp converter
check "convertToPDS"





