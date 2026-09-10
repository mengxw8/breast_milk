package com.posprinter.printdemo.activity

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.posprinter.printdemo.App
import com.posprinter.printdemo.R
import com.posprinter.printdemo.databinding.ActivityPosBinding
import com.posprinter.printdemo.utils.UIUtils
import com.posprinter.printdemo.widget.ModifyBtDlg
import com.posprinter.printdemo.widget.ModifyNetDlg
import com.posprinter.printdemo.widget.ModifyWifiDlg
import net.posprinter.POSConst
import net.posprinter.POSPrinter
import net.posprinter.model.PTable
import java.nio.charset.Charset

class PosActivity : AppCompatActivity() {
    private val printer = POSPrinter(App.get().curConnect)
    private lateinit var bind: ActivityPosBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        bind = ActivityPosBinding.inflate(layoutInflater)
        setContentView(bind.root)
        initListener()
    }

    private fun initListener() {
        bind.btText.setOnClickListener {
            printText()
        }
        bind.btbarcode.setOnClickListener {
            printBarcode()
        }
        bind.btpic.setOnClickListener {
            val bmp = BitmapFactory.decodeResource(resources, R.drawable.nv_test)
            printPicCode(bmp)
        }
        bind.qrcode.setOnClickListener { printQRCode() }

        bind.printerStatusBtn.setOnClickListener {
            printer.printerStatusII {
                when (it) {
                    POSConst.CONNECT_ERROR -> {
                        UIUtils.toast("Connect Error")
                    }
                    POSConst.READ_TIMEOUT -> {
                        UIUtils.toast("Read timeout")
                    }
                    0 -> {
                        UIUtils.toast("Ready")
                    }
                    else -> {
                        val sb = StringBuilder()
                        if ((it and 0b1) > 0) {
                            sb.append("Printing, ")
                        }
                        if ((it and 0b10) > 0) {
                            sb.append("Cover opened, ")
                        }
                        if ((it and 0b100) > 0) {
                            sb.append("Out of paper, ")
                        }
                        if ((it and 0b1000) > 0) {
                            sb.append("Paper near end, ")
                        }
                        if ((it and 0b10000) > 0) {
                            sb.append("Cash drawer is open, ")
                        }
                        if ((it and 0b100000) > 0) {
                            sb.append("Other Error, ")
                        }
                        if ((it and 0b1000000) > 0) {
                            sb.append("Cutter error, ")
                        }
                        if ((it and 0b10000000) > 0) {
                            sb.append("Print head overheating, ")
                        }
                        UIUtils.toast(sb.toString())
                    }
                }
            }
        }
        bind.openDrawer.setOnClickListener {
            printer.openCashBox(POSConst.PIN_TWO)
        }
        bind.tableBtn.setOnClickListener {
            val table = PTable(arrayOf("Item", "QTY", "Price", "Total"), arrayOf(13, 10, 10, 11), arrayOf(0, 0, 1, 1))
                .addRow("Apple Apple xxxxxxxxxxxxx", arrayOf("100328", "1", "7.99", "7.99"), "remarks:xxxxxxxx")
                .addRow("680015", "4", "0.99", "3.96")
                .addRow("102501102501102501", "1", "43.99", "43.99")
                .addRow("021048", "1", "4.99", "4.99")
            printer.initializePrinter()
                .printTable(table)
                .feedLine(2)
                .cutHalfAndFeed(1)
        }
        bind.wifiConfigBtn.setOnClickListener {
            ModifyWifiDlg(this, printer).show()
        }
        bind.setNetBtn.setOnClickListener {
            ModifyNetDlg(this, printer).show()
        }
        bind.setBleBtn.setOnClickListener {
            ModifyBtDlg(this, printer).show()
        }
        bind.querySerialNumberBtn.setOnClickListener {
            printer.getSerialNumber {
                UIUtils.toast("SN:${String(it, Charset.defaultCharset())}")
            }
        }
        bind.setIpViaUdpBtn.setOnClickListener {
            val intent = Intent(this, SelectNetActivity::class.java)
            intent.putExtra("data", SelectNetActivity.OPT_MODIFY)
            startActivity(intent)
        }
        bind.imageCompressBtn.setOnClickListener {
            val bmp = BitmapFactory.decodeResource(resources, R.drawable.nv_test)
            printer.initializePrinter()
                .printBitmapCompress(bmp, POSConst.ALIGNMENT_CENTER, 384)
                .feedLine(5)
        }
    }

    private fun printText() {
        val str = "Welcome to the printer,this is print test content!\n"
        printer.initializePrinter()
            .printString(str)
            .printText(
                "printText Demo\n",
                POSConst.ALIGNMENT_CENTER,
                POSConst.FNT_BOLD or POSConst.FNT_UNDERLINE,
                POSConst.TXT_1WIDTH or POSConst.TXT_2HEIGHT
            )
            .cutHalfAndFeed(1)
    }

    private fun printBarcode() {
        printer.initializePrinter()
            .printString("UPC-A\n")
            .printBarCode("123456789012", POSConst.BCS_UPCA)
            .printString("UPC-E\n")
            .printBarCode("042100005264", POSConst.BCS_UPCE, 2, 70, POSConst.ALIGNMENT_LEFT)//425261
            .printString("JAN8\n")
            .printBarCode("12345678", POSConst.BCS_JAN8, 2, 70, POSConst.ALIGNMENT_CENTER)
            .printString("JAN13\n")
            .printBarCode("123456791234", POSConst.BCS_JAN13, 2, 70, POSConst.ALIGNMENT_RIGHT)
            .printString("CODE39\n")
            .printBarCode(
                "ABCDEFGHI",
                POSConst.BCS_Code39,
                2,
                70,
                POSConst.ALIGNMENT_CENTER,
                POSConst.HRI_TEXT_BOTH
            )
            .printString("ITF\n")
            .printBarCode("123456789012", POSConst.BCS_ITF, 70)
            .printString("CODABAR\n")
            .printBarCode("A37859B", POSConst.BCS_Codabar, 70)
            .printString("CODE93\n")
            .printBarCode("123456789", POSConst.BCS_Code93, 70)
            .printString("CODE128\n")
            .printBarCode("{BNo.123456", POSConst.BCS_Code128, 2, 70, POSConst.ALIGNMENT_LEFT)
            .feedLine()
            .cutHalfAndFeed(1)
    }

    private fun printQRCode() {
        val content =
            "Welcome to Printer Technology to create advantages Quality to win in the future"
        printer.initializePrinter()
            .printQRCode(content)
            .feedLine()
            .cutHalfAndFeed(1)
    }


    //let the printer print bitmap
    private fun printPicCode(printBmp: Bitmap) {
        printer.initializePrinter()
            .printBitmap(printBmp, POSConst.ALIGNMENT_CENTER, 384)
            .feedLine()
            .cutHalfAndFeed(1)
    }
}