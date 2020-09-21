package com.manoilo.contact_list


data class Contact(val id: String, val displayName: String) {
    var avatar: ByteArray? = null

    fun toMap(): HashMap<String, Any?> {
        val contactMap: HashMap<String, Any?> = HashMap()
        contactMap["identifier"] = id
        contactMap["displayName"] = displayName
        contactMap["avatar"] = avatar
        return contactMap
    }
}