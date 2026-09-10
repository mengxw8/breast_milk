package com.posprinter.printdemo.activity

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.posprinter.printdemo.App
import com.posprinter.printdemo.R
import com.posprinter.printdemo.databinding.ActivityPosTaskBinding
import net.posprinter.POSConst
import net.posprinter.POSPrinter
import net.posprinter.model.IReceive
import net.posprinter.model.PTable
import java.text.SimpleDateFormat
import java.util.Date

class PosTaskActivity : AppCompatActivity() {
    private val df: SimpleDateFormat = SimpleDateFormat("HH:mm:ss.SSS")

    private val printer = POSPrinter(App.get().curConnect)
    private lateinit var bind: ActivityPosTaskBinding
    private var taskId = 1L

    private fun parseReceive(data: IReceive) {
        addMsg(data.toString())
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        bind = ActivityPosTaskBinding.inflate(layoutInflater)
        setContentView(bind.root)
        printer.listenPrinterMessage {
            parseReceive(it)
        }
        initListener()
    }
    private var msgSb = kotlin.text.StringBuilder()
    private fun addMsg(msg: String) {
        if (msgSb.length > 10000) {
            msgSb.setLength(1000)
        }
        msgSb.insert(0, df.format(Date()) +":" + msg +"\n")
        bind.msgTv.setText(msgSb.toString())
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
            printer.printerStatus()
        }
        bind.tableBtn.setOnClickListener {
            val table = PTable(
                arrayOf("Item", "QTY", "Price", "Total"),
                arrayOf(13, 10, 10, 11),
                arrayOf(0, 0, 1, 1)
            )
                .addRow("Apple Apple xxxxxxxxxxxxx", arrayOf("100328", "1", "7.99", "7.99"), "remarks:xxxxxxxx")
                .addRow("680015", "4", "0.99", "3.96")
                .addRow("102501102501102501", "1", "43.99", "43.99")
                .addRow("021048", "1", "4.99", "4.99")
            printer.taskStart(taskId)
                .initializePrinter()
                .printTable(table)
                .feedLine(2)
                .cutHalfAndFeed(1)
                .taskEnd(taskId++)
        }
        bind.imageCompressBtn.setOnClickListener {
            val bmp = BitmapFactory.decodeResource(resources, R.drawable.nv_test)
            printer.taskStart(taskId)
                .initializePrinter()
                .printBitmapCompress(bmp, POSConst.ALIGNMENT_CENTER, 384)
                .feedLine(5)
                .taskEnd(taskId++)
        }
        bind.firmwareVersionBtn.setOnClickListener {
            printer.checkFirmwareVersion()
        }
    }

    private fun printText() {
        val str = "Welcome to the printer,this is print test content!\n"
        printer.taskStart(taskId)
            .initializePrinter()
            .printString(str)
            .printText(
                "printText Demo\n",
                POSConst.ALIGNMENT_CENTER,
                POSConst.FNT_BOLD or POSConst.FNT_UNDERLINE,
                POSConst.TXT_1WIDTH or POSConst.TXT_2HEIGHT
            )
            .cutHalfAndFeed(1)
            .taskEnd(taskId++)
    }

    private fun printBarcode() {
        printer.taskStart(taskId)
            .initializePrinter()
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
            .taskEnd(taskId++)
    }

    private fun printQRCode() {
        val content =
            "Welcome to Printer Technology to create advantages Quality to win in the future"
        printer.taskStart(taskId)
            .initializePrinter()
            .printQRCode(content)
            .feedLine()
            .cutHalfAndFeed(1)
            .taskEnd(taskId++)
    }


    //let the printer print bitmap
    private fun printPicCode(printBmp: Bitmap) {
        printer.taskStart(taskId)
            .initializePrinter()
            .printBitmap(printBmp, POSConst.ALIGNMENT_CENTER, 384)
            .feedLine()
            .cutHalfAndFeed(1)
            .taskEnd(taskId++)
    }

    override fun onDestroy() {
        super.onDestroy()
        printer.stopListenPrinterMessage()
    }
}