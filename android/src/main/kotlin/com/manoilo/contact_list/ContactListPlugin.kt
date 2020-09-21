package com.manoilo.contact_list

import android.content.ContentResolver
import android.content.ContentUris
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.provider.ContactsContract
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.util.*
import kotlin.Comparator
import kotlin.collections.ArrayList
import kotlin.collections.LinkedHashMap


/** ContactListPlugin */
const val CHANNEL = "com.manoilo.contact_list"
const val LOG_TAG = "ContactListPlugin"

class ContactListPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var contentResolver: ContentResolver

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, CHANNEL)
        channel.setMethodCallHandler(this)
        this.contentResolver = flutterPluginBinding.applicationContext.contentResolver
    }


    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL)
            channel.setMethodCallHandler(ContactListPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getContacts") {

            GlobalScope.launch(Dispatchers.Main) {
                result.success(getContactsJob())
            }

        } else {
            result.notImplemented()
        }
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private suspend fun getContactsJob(): ArrayList<Map<String, Any?>> {
        return GlobalScope.async(Dispatchers.IO) {
            val contacts = getContacts(getCursor())

            for (contact in contacts) {
                val avatar: ByteArray? = loadContactPhotoHighRes(contact.id, contentResolver)
                contact.avatar = avatar
            }


            val compareByGivenName: Comparator<Contact> = Comparator { contactA, contactB -> contactA.displayName.compareTo(contactB.displayName) }
            Collections.sort(contacts, compareByGivenName)

            val contactMaps = ArrayList<Map<String, Any?>>()
            for (contact in contacts) {
                contactMaps.add(contact.toMap())
            }
            return@async contactMaps
        }.await()
    }

    private fun loadContactPhotoHighRes(identifier: String, contentResolver: ContentResolver): ByteArray? {
        return try {
            val uri: Uri = ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, identifier.toLong())
            val input = ContactsContract.Contacts.openContactPhotoInputStream(contentResolver, uri, true)
                    ?: return null
            val bitmap = BitmapFactory.decodeStream(input)
            input.close()
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            val bytes: ByteArray = stream.toByteArray()
            stream.close()
            bytes
        } catch (ex: IOException) {
            Log.e(LOG_TAG, ex.message)
            null
        }
    }

    private fun getContacts(cursor: Cursor?): ArrayList<Contact> {
        val map: HashMap<String, Contact> = LinkedHashMap()
        while (cursor != null && cursor.moveToNext()) {
            val columnIndex: Int = cursor.getColumnIndex(ContactsContract.Data.CONTACT_ID)

            val contactId: String = cursor.getString(columnIndex)

            val displayName = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME_PRIMARY))
            val contact = Contact(contactId, displayName)
            if (!map.containsKey(contactId)) {
                map[contactId] = contact
            }
        }
        cursor?.close()
        return ArrayList(map.values)
    }

    private fun getCursor() =
            contentResolver.query(ContactsContract.Data.CONTENT_URI, arrayOf(ContactsContract.Data.CONTACT_ID,
                    ContactsContract.Profile.DISPLAY_NAME), null, null, null)
}
