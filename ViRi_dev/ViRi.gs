<?xml version="1.0" encoding="UTF-8"?><project xmlns="http://grogra.de/registry" graph="graph.xml">
 <import plugin="de.grogra.rgg" version="1.6"/>
 <import plugin="de.grogra.math" version="1.6"/>
 <import plugin="de.grogra.imp" version="1.6"/>
 <import plugin="de.grogra.pf" version="1.6"/>
 <import plugin="de.grogra.imp3d" version="1.6"/>
 <registry>
  <ref name="project">
   <ref name="objects">
    <ref name="files">
     <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pfs:Light.rgg"/>
     <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pfs:Globals.rgg"/>
     <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pfs:Functions.rgg"/>
     <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pfs:main_Develop.rgg"/>
     <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pfs:input_output.rgg"/>
     <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pfs:methods_plant.rgg"/>
     <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pfs:methods_management.rgg"/>
     <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pfs:methods_simulation.rgg"/>
     <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pfs:modules_plant.rgg"/>
     <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pfs:modules_light.rgg"/>
     <de.grogra.pf.ui.registry.SourceFile mimeType="text/x-grogra-rgg" name="pfs:modules_scene.rgg"/>
    </ref>
    <ref name="meta">
     <de.grogra.pf.registry.NodeReference name="Light" ref="59839300"/>
     <de.grogra.pf.registry.NodeReference name="Globals" ref="59839301"/>
     <de.grogra.pf.registry.NodeReference name="Functions" ref="59839302"/>
     <de.grogra.pf.registry.NodeReference name="main_Develop" ref="59839303"/>
     <de.grogra.pf.registry.NodeReference name="input_output" ref="59839304"/>
     <de.grogra.pf.registry.NodeReference name="methods_plant" ref="59839305"/>
     <de.grogra.pf.registry.NodeReference name="methods_management" ref="59839306"/>
     <de.grogra.pf.registry.NodeReference name="methods_simulation" ref="59839307"/>
     <de.grogra.pf.registry.NodeReference name="modules_plant" ref="59839308"/>
     <de.grogra.pf.registry.NodeReference name="modules_light" ref="59839309"/>
     <de.grogra.pf.registry.NodeReference name="modules_scene" ref="59839310"/>
    </ref>
   </ref>
  </ref>
  <ref name="workbench">
   <ref name="state">
    <de.grogra.pf.ui.registry.Layout name="layout">
     <de.grogra.pf.ui.registry.MainWindow>
      <de.grogra.pf.ui.registry.Split orientation="0">
       <de.grogra.pf.registry.Link source="/ui/panels/rgg/toolbar"/>
       <de.grogra.pf.ui.registry.Split location="0.4375">
        <de.grogra.pf.ui.registry.Split location="0.6796116" orientation="0">
         <de.grogra.pf.ui.registry.PanelFactory source="/ui/panels/3d/defaultview">
          <de.grogra.pf.registry.Option name="panelId" type="java.lang.String" value="/ui/panels/3d/defaultview"/>
          <de.grogra.pf.registry.Option name="panelTitle" type="java.lang.String" value="View"/>
          <de.grogra.pf.registry.Option name="view" type="de.grogra.imp3d.View3D" value="graphDescriptor=[de.grogra.imp.ProjectGraphDescriptor]visibleScales={true true true true true true true true true true true true true true true}visibleLayers={true true true true true true true true true true true true true true true true}epsilon=1.0E-6 visualEpsilon=0.01 magnitude=1.0 camera=(minZ=0.1 maxZ=2000.0 projection=[de.grogra.imp3d.PerspectiveProjection aspect=1.0 fieldOfView=1.0471976]transformation=(0.5151057348901863 -0.8571266428498849 0.0 -7.148605374318606E-8 0.45654978441019695 0.2743718377842538 0.8463346790627819 -0.8463651173762328 -0.7254160021926583 -0.4359518468217647 0.532651491140373 -14.730024048822207 0.0 0.0 0.0 1.0))navigator=null"/>
         </de.grogra.pf.ui.registry.PanelFactory>
         <de.grogra.pf.ui.registry.Tab selectedIndex="1">
          <de.grogra.pf.registry.Link source="/ui/panels/statusbar"/>
          <de.grogra.pf.registry.Link source="/ui/panels/fileexplorer"/>
         </de.grogra.pf.ui.registry.Tab>
        </de.grogra.pf.ui.registry.Split>
        <de.grogra.pf.ui.registry.Split location="0.55124056" orientation="0">
         <de.grogra.pf.ui.registry.Tab selectedIndex="0">
          <de.grogra.pf.ui.registry.PanelFactory source="/ui/panels/texteditor">
           <de.grogra.pf.registry.Option name="documents" type="java.lang.String" value="&quot;\&quot;pfs:Light.rgg\&quot;,\&quot;pfs:main_Develop.rgg\&quot;,\&quot;pfs:Untitled-1\&quot;&quot;"/>
           <de.grogra.pf.registry.Option name="panelId" type="java.lang.String" value="/ui/panels/texteditor"/>
           <de.grogra.pf.registry.Option name="panelTitle" type="java.lang.String" value="jEdit - main_Develop.rgg"/>
           <de.grogra.pf.registry.Option name="selected" type="java.lang.String" value="pfs:main_Develop.rgg"/>
          </de.grogra.pf.ui.registry.PanelFactory>
          <de.grogra.pf.registry.Link source="/ui/panels/attributeeditor"/>
         </de.grogra.pf.ui.registry.Tab>
         <de.grogra.pf.ui.registry.Tab selectedIndex="2">
          <de.grogra.pf.registry.Link source="/ui/panels/log"/>
          <de.grogra.pf.registry.Link source="/ui/panels/objects/meta"/>
          <de.grogra.pf.registry.Link source="/ui/panels/rgg/console"/>
         </de.grogra.pf.ui.registry.Tab>
        </de.grogra.pf.ui.registry.Split>
       </de.grogra.pf.ui.registry.Split>
      </de.grogra.pf.ui.registry.Split>
     </de.grogra.pf.ui.registry.MainWindow>
    </de.grogra.pf.ui.registry.Layout>
   </ref>
  </ref>
 </registry>
</project>
