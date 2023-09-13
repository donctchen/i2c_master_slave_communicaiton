# FPGA實作I2C Master和Slave溝通

## 實作內容
使用I2C通訊方式，實作Master和Slave <BR>
寫入資料後讀取資料<BR>
驗證讀取資料和寫入資料相同: 測試成功 <BR>
點亮LED表示測試成功<BR>
並在 7 Segment 顯示PASS<BR>

![alt text](fpga.jpg)

![alt text](post_imp_sim.png)

## 上層模組
i2c_top.v

## Basys3 constraint file
Basys3_Master.xdc


## 參考
### I2C Master module
- DigiKey I2C Master VHDL code
- https://forum.digikey.com/t/i2c-master-vhdl/12797
 
