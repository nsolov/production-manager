Class RestProduction.Demo.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="RestProduction.Demo.Production">
  <ActorPoolSize>1</ActorPoolSize>
  <Item Name="BO1" 
        ClassName="RestProduction.Demo.Operation" 
        PoolSize="1" Enabled="true" Foreground="false" InactivityTimeout="0">
  </Item>
</Production>
}

}
