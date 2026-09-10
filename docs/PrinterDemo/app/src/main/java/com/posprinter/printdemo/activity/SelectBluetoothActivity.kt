package com.posprinter.printdemo.activity

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.activity.result.ActivityResult
import androidx.activity.result.contract.ActivityResultContracts.StartActivityForResult
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.posprinter.printdemo.R
import com.posprinter.printdemo.databinding.ActivitySelectBlutoothBinding
import com.posprinter.printdemo.utils.UIUtils
import io.reactivex.rxjava3.core.Flowable
import java.util.concurrent.TimeUnit


/**
 * @author: star
 * @date: 2022-04-26
 */
@SuppressLint("MissingPermission", "NotifyDataSetChanged")
class SelectBluetoothActivity : AppCompatActivity() {
    private lateinit var bind: ActivitySelectBlutoothBinding
    private val GPS_ACTION = "android.location.PROVIDERS_CHANGED"
    private val REQUEST_CODE_BLUETOOTH_PERMISSIONS = 10020

    companion object {
        const val INTENT_MAC = "MAC"
    }

    private val datas = ArrayList<BtAdapter.Bean>()
    private var isDiscovering = false
    private val bluetoothAdapter: BluetoothAdapter by lazy {
        (getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager).adapter
    }
    private val launcher =
        registerForActivityResult(StartActivityForResult()) { result: ActivityResult ->
            if (result.resultCode == RESULT_OK) {
                requestPermission()
            } else {
                UIUtils.toast(R.string.request_permission_fail)
            }
        }
    private val mBroadcastReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action
            if (BluetoothDevice.ACTION_FOUND == action) {
                val btd = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                if (btd?.type == 2) return
                if (btd!!.bondState != BluetoothDevice.BOND_BONDED && !deviceIsExist(btd.address)) {
                    var name = btd.name
                    if (name == null) name = "none"
                    val rssi = intent.extras!!.getShort(BluetoothDevice.EXTRA_RSSI).toInt()
                    datas.add(BtAdapter.Bean(false, name, btd.address, rssi))
                    bind.recyclerView.adapter?.notifyItemChanged(datas.size - 1)
                }
            } else if (action == GPS_ACTION) {
                if (isGpsOpen()) {
                    setBluetooth()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        bind = ActivitySelectBlutoothBinding.inflate(layoutInflater)
        setContentView(bind.root)
        bind.recyclerView.layoutManager = LinearLayoutManager(this)
        val adapter = BtAdapter(datas)
        adapter.itemClick = {
            val intent = Intent()
            intent.putExtra(INTENT_MAC, datas[it].mac)
            setResult(RESULT_OK, intent)
            finish()
        }
        bind.recyclerView.adapter = adapter

        val intentFilter = IntentFilter()
        intentFilter.addAction(BluetoothDevice.ACTION_FOUND)
        intentFilter.addAction(GPS_ACTION)
        registerReceiver(mBroadcastReceiver, intentFilter)
        requestPermission()
        initClick()
    }

    private fun initClick() {
        bind.refreshTv.setOnClickListener {
            requestPermission()
        }
    }

    private fun checkBluetoothPermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED
                    && ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
                    && ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun requestPermission() {
        val permissionsToRequest = ArrayList<String>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissionsToRequest.add(Manifest.permission.BLUETOOTH_SCAN)
            permissionsToRequest.add(Manifest.permission.BLUETOOTH_CONNECT)
            permissionsToRequest.add(Manifest.permission.ACCESS_FINE_LOCATION)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            permissionsToRequest.add(Manifest.permission.ACCESS_FINE_LOCATION)
        }

        if (!checkBluetoothPermissions() && permissionsToRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this,
                permissionsToRequest.toTypedArray<String>(),
                REQUEST_CODE_BLUETOOTH_PERMISSIONS
            )
        }else{
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || isGpsOpen()) {
                setBluetooth()
            } else {
                openGPS()
            }
        }
    }

    private var lastTime = 0L
    private fun setBluetooth() {
        if (System.currentTimeMillis() - lastTime < 1000) {
            return
        }
        lastTime = System.currentTimeMillis()
        if (!bluetoothAdapter.isEnabled) {
            val intent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            launcher.launch(intent)
        } else {
            searchDevices()
        }
    }

    private fun searchDevices() {
        datas.clear()
        val device: Set<BluetoothDevice> = bluetoothAdapter.bondedDevices
        device.forEach {
            val name = it.name ?: "none"
            datas.add(BtAdapter.Bean(true, name, it.address,0))
        }
        bind.recyclerView.adapter?.notifyDataSetChanged()
        if (bluetoothAdapter.isDiscovering) {
            bluetoothAdapter.cancelDiscovery()
        }
        isDiscovering = true
        Flowable.timer(300, TimeUnit.MILLISECONDS)
            .subscribe {
                bluetoothAdapter.startDiscovery()
            }
    }

    private fun deviceIsExist(mac: String): Boolean {
        datas.forEach {
            if (it.mac == mac) {
                return true
            }
        }
        return false
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_BLUETOOTH_PERMISSIONS) {
            var allGranted = true
            for (result in grantResults) {
                if (result != PackageManager.PERMISSION_GRANTED) {
                    allGranted = false
                    break
                }
            }
            if (allGranted) {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || isGpsOpen()) {
                    setBluetooth()
                } else {
                    openGPS()
                }
            } else {
                UIUtils.toast(getString(R.string.request_permission_fail))
            }
        }
    }

    private fun isGpsOpen(): Boolean {
        val locationManager: LocationManager = getSystemService(LOCATION_SERVICE) as LocationManager
        val gps = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
        val network: Boolean = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        return gps || network
    }

    private fun openGPS() {
        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
        startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isDiscovering && bluetoothAdapter.isDiscovering) {
            bluetoothAdapter.cancelDiscovery()
        }
        unregisterReceiver(mBroadcastReceiver)
    }
}
