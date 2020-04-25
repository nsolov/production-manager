Class Demo.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Demo.Production">
  <ActorPoolSize>1</ActorPoolSize>
  <Item Name="BO1" 
        ClassName="Demo.Operation" 
        PoolSize="1" Enabled="true" Foreground="false" InactivityTimeout="0">
  </Item>
</Production>
}

}
