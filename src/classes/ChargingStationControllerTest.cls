@isTest
public class ChargingStationControllerTest {

    @isTest
    static void test1(){
        Contact con = new Contact(LastName='Sample');
        INSERT con;
        ChargingStationController.createChargingRecord(con.Id);
        ChargingStationController.updateChargingRecord(con.Id);
    }
}