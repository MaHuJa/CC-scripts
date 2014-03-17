<map version="1.0.1">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1394912267897" ID="ID_1163523493" MODIFIED="1395072991560" TEXT="Reactor control readme">
<node CREATED="1395070117575" ID="ID_39759696" MODIFIED="1395070120491" POSITION="right" TEXT="About the program">
<node CREATED="1395070126973" ID="ID_753589744" MODIFIED="1395070383661" TEXT="The program is intended to automate any ic2 reactor setup. &#xa;The software is not yet complete; features are prioritized according to what I need for my reactor(s)."/>
</node>
<node CREATED="1395070737427" ID="ID_938939941" MODIFIED="1395070743459" POSITION="right" TEXT="Requirements">
<node CREATED="1395070790553" ID="ID_1346317650" MODIFIED="1395070804974" TEXT="ComputerCraft OR OpenComputers">
<node CREATED="1395070806743" ID="ID_770470904" MODIFIED="1395070815260" TEXT="Opencomputers support not complete"/>
</node>
<node CREATED="1395070818222" ID="ID_1301181691" MODIFIED="1395070846236" TEXT="OpenPeripherals compatible inventory API">
<node CREATED="1395072426270" ID="ID_1362057300" MODIFIED="1395072464404" TEXT="In particular, pushItem and pullItem, getAllStacks, getStackInSlot."/>
</node>
</node>
<node CREATED="1395070745151" ID="ID_1079068326" MODIFIED="1395070752396" POSITION="right" TEXT="Hardware setup">
<node CREATED="1395070900446" ID="ID_1497357567" MODIFIED="1395071894023" TEXT="REACTOR: The reactor must be set up with the component pattern you wish to use, and must be connected as a peripheral/component."/>
<node CREATED="1395071074316" ID="ID_1498861376" MODIFIED="1395071192694" TEXT="SUPPLIER: An inventory which will contain the reactor components that will be moved into the reactor as needed. Must be connected as a peripheral/component."/>
<node CREATED="1395071284091" FOLDED="true" ID="ID_485339793" MODIFIED="1395072150342" TEXT="PULLER: An inventory which will receive components removed from the reactor. Must be connected as a peripheral/component.">
<node CREATED="1395071440178" ID="ID_1508308021" MODIFIED="1395071497719" TEXT="May be the same inventory as the supplier, as long as one can prevent it getting pulled back in.. See also ME Interface."/>
<node CREATED="1395071503194" ID="ID_761536006" MODIFIED="1395071579773" TEXT="May receive items like">
<node CREATED="1395071516262" ID="ID_1353549001" MODIFIED="1395071519383" TEXT="Spent fuel"/>
<node CREATED="1395071519764" ID="ID_647226810" MODIFIED="1395071526683" TEXT="Empty condensers"/>
<node CREATED="1395071527078" ID="ID_1077090446" MODIFIED="1395071546413" TEXT="Hot cooling cells/OC vents meant for cooling elsewhere."/>
</node>
</node>
<node CREATED="1395071613144" FOLDED="true" ID="ID_768289821" MODIFIED="1395072291969" TEXT="REDSTONE SOURCE: Software controlled device emitting the redstone signal that activates the reactor.">
<node CREATED="1395072130670" ID="ID_1552683201" MODIFIED="1395072140709" TEXT="With a CC computer, this will be the computer itself."/>
<node CREATED="1395071821081" ID="ID_558597129" MODIFIED="1395071835290" TEXT="The reactor MUST NOT run unless  this signal is active."/>
</node>
<node CREATED="1395072063386" ID="ID_1354873535" MODIFIED="1395072394798" TEXT="(Optional) POWER STORAGE: The software can be configured to stop the reactor if nothing will receive its power output.">
<icon BUILTIN="stop"/>
</node>
<node CREATED="1395072000575" ID="ID_185042024" MODIFIED="1395072056856" TEXT="(Optional) NETWORK INTERFACE: The software will broadcast status reports on the network."/>
<node CREATED="1395072192364" ID="ID_1915896275" MODIFIED="1395072390847" TEXT="(Optional) MONITOR: Used to display status reports">
<icon BUILTIN="prepare"/>
</node>
</node>
<node CREATED="1395070764332" ID="ID_1024390177" MODIFIED="1395070767429" POSITION="right" TEXT="Software installation"/>
<node CREATED="1395070769209" ID="ID_305496142" MODIFIED="1395070772238" POSITION="right" TEXT="Configuration">
<node CREATED="1395072335959" ID="ID_1878506054" MODIFIED="1395072342721" TEXT="Config file"/>
<node CREATED="1395072343081" ID="ID_1993850453" MODIFIED="1395072345684" TEXT="Reactor table"/>
<node CREATED="1395072373192" ID="ID_1863292851" MODIFIED="1395072945721" TEXT="Customize logging/status updates"/>
</node>
<node CREATED="1395070775764" ID="ID_1125473616" MODIFIED="1395072278727" POSITION="right" TEXT="Running &amp; Maintenance">
<node CREATED="1395072501375" ID="ID_1336613672" MODIFIED="1395072523605" TEXT="The software will report what mode it is in"/>
</node>
</node>
</map>
