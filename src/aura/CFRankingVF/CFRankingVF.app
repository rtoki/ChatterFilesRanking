<aura:application access="GLOBAL" extends="ltng:outApp">
        <aura:attribute access="global" name="group" type="String" default="" />
		<c:CFRanking group='{!v.group}'/>
</aura:application>