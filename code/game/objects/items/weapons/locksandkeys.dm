/*

Items for locking doors and chests

*/

//Locks and Keys

/obj/item/weapon/lock/lock_assy
  name = "lock assembly"
  desc = "This is a simple lock assembly for securing doors and chests."
  icon = 'icons/obj/items.dmi'
  icon_state = "lock_assy" // PLACEHOLDER
  w_class = WEIGHT_CLASS_NORMAL


/obj/item/weapon/lock/key
  name = "key"
  desc = "A small key used for opening things."
  icon = 'icons/obj/items.dmi'
  icon_state = "key" // PLACEHOLDER
  w_class = WEIGHT_CLASS_TINY

  var/keycode = 0

/obj/item/weapon/storage/keyring
  name = "keyring"
  desc = "A keyring for storing keys"
  icon = 'icons/obj/items.dmi'
  icon_state = "keyring"
  w_class = WEIGHT_CLASS_TINY
  storage_slots = 10
  can_hold = list(
    /obj/item/weapon/lock/key
    )

/obj/item/weapon/lock/key/verb/rename()
  set name = "Rename Key"
  set category = "Object"
  set src in usr

  if(usr.incapacitated())
    return
  if(ishuman(usr))
    var/k_name = stripped_input(usr, "What would you like to label the key?", "Key Label", null)
    if((loc == usr && usr.stat ==0))
      name = "key ([k_name])"
      add_fingerprint(usr)
