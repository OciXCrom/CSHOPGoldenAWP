#include <amxmodx>
#include <cstrike>
#include <customshop>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

#define PLUGIN_VERSION "1.0.1"
#define V_MODEL "models/custom_shop/v_golden_awp.mdl"
#define P_MODEL "models/custom_shop/p_golden_awp.mdl"

additem ITEM_GOLDEN_AWP
new g_bHasItem[33], g_szDamage[16], g_iBPAmmo

public plugin_init()
{
	register_plugin("CSHOP: Golden AWP", PLUGIN_VERSION, "OciXCrom")
	register_cvar("CRXSHOPGoldenAWP", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	register_event("CurWeapon", "OnSelectAWP", "be", "1=1", "2=18")
	RegisterHam(Ham_TakeDamage, "player", "PreTakeDamage", 0)
	cshop_get_string(ITEM_GOLDEN_AWP, "Damage", g_szDamage, charsmax(g_szDamage))
	g_iBPAmmo = cshop_get_int(ITEM_GOLDEN_AWP, "Backpack Ammo")
}

public plugin_precache()
{
	ITEM_GOLDEN_AWP = cshop_register_item("goldenawp", "Golden AWP", 9500)
	cshop_set_string(ITEM_GOLDEN_AWP, "Damage", "+100%")
	cshop_set_int(ITEM_GOLDEN_AWP, "Backpack Ammo", 30)

	#if defined V_MODEL
	precache_model(V_MODEL)
	#endif

	#if defined P_MODEL
	precache_model(P_MODEL)
	#endif
}

public cshop_item_selected(id, iItem)
{
	if(iItem == ITEM_GOLDEN_AWP)
	{
		g_bHasItem[id] = true

		if(get_user_weapon(id) == CSW_AWP)
			RefreshAWPModel(id)
		else if(!user_has_weapon(id, CSW_AWP))
			give_item(id, "weapon_awp")

		cs_set_user_bpammo(id, CSW_AWP, g_iBPAmmo)
	}
}

public cshop_item_removed(id, iItem)
{
	if(iItem == ITEM_GOLDEN_AWP)
		g_bHasItem[id] = false
}

public client_putinserver(id)
	g_bHasItem[id] = false

public OnSelectAWP(id)
{	
	if(g_bHasItem[id])
		RefreshAWPModel(id)
}

public PreTakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDamageBits)
{
	if(is_user_alive(iAttacker) && iAttacker != iVictim && g_bHasItem[iAttacker])
		SetHamParamFloat(4, math_add_f(fDamage, g_szDamage))
}

RefreshAWPModel(const id)
{
	#if defined V_MODEL
	set_pev(id, pev_viewmodel2, V_MODEL)
	#endif

	#if defined P_MODEL
	set_pev(id, pev_weaponmodel2, P_MODEL)
	#endif
}

Float:math_add_f(Float:fNum, const szMath[])
{
	static szNewMath[16], Float:fMath, bool:bPercent, cOperator
   
	copy(szNewMath, charsmax(szNewMath), szMath)
	bPercent = szNewMath[strlen(szNewMath) - 1] == '%'
	cOperator = szNewMath[0]
   
	if(!isdigit(szNewMath[0]))
		szNewMath[0] = ' '
   
	if(bPercent)
		replace(szNewMath, charsmax(szNewMath), "%", "")
	   
	trim(szNewMath)
	fMath = str_to_float(szNewMath)
   
	if(bPercent)
		fMath *= fNum / 100
	   
	switch(cOperator)
	{
		case '+': fNum += fMath
		case '-': fNum -= fMath
		case '/': fNum /= fMath
		case '*': fNum *= fMath
		default: fNum = fMath
	}
   
	return fNum
}  
