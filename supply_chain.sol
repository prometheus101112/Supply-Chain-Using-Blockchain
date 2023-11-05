// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    enum Status { Created, InTransit, Delivered }
    enum Roles {Manufacturer, Shipper, Customer}
    struct Product {
        uint productId;
        string productName;
        uint quantity;
    }

    struct Order {
        uint orderId;
        uint productId;
        uint quantity;
        address buyer;
        Status status;
    }

    struct Shipment {
        uint shipmentId;
        uint orderId;
        address logisticsProvider;
        Status status;
    }
    mapping(address => Roles) public role;
    mapping(uint => Product) public products;
    mapping(uint => Order) public orders;
    mapping(uint => Shipment) public shipments;
    constructor(){
        role[0x151A661873D687d56551CAF5d63bd8DEB1217520] = Roles.Manufacturer;
        role[0x1755A75e777f07EFbbb411cB30cCd2fBD9868Bcc] = Roles.Shipper;
        role[0x77A8D5e6E3D6B383D7D48b3D58301Ad3cbc36f1E] = Roles.Customer;
    }
    uint public productCount;
    uint public orderCount;
    uint public shipmentCount;
    uint public curr_role;
    bool public ship_verify;
    bool public cust_verify;

    event ProductCreated(uint productId, string productName, uint quantity);
    event OrderCreated(uint orderId, uint productId, uint quantity, address buyer);
    event ShipmentCreated(uint shipmentId, uint orderId, address logisticsProvider);

    modifier onlyManufacturer() {
        require(role[msg.sender] == Roles.Manufacturer, "Only a manufacturer can call this function");
        _;
    }
    modifier onlyShipper() {
        require(role[msg.sender] == Roles.Shipper, "Only a shipper can call this function");
        _;
    }
    modifier onlyCustomer() {
        require(role[msg.sender] == Roles.Customer, "Only a customer can call this function");
        _;
    }
    
    function createProduct(string memory _productName, uint _quantity) public onlyManufacturer {
        productCount++;
        products[productCount] = Product(productCount, _productName, _quantity);
        emit ProductCreated(productCount, _productName, _quantity);
    }

    function createOrder(uint _productId, uint _quantity) public onlyCustomer{
        require(_productId > 0, "Invalid product ID");
        require((bytes(products[_productId].productName).length != 0) ,"Product does not exist");
        require(products[_productId].quantity >= _quantity, "Insufficient product quantity");
        orderCount++;
        products[_productId].quantity -= _quantity;
        orders[orderCount] = Order(orderCount, _productId, _quantity, msg.sender, Status.Created);
        emit OrderCreated(orderCount, _productId, _quantity, msg.sender);
    }

    function createShipment(uint _orderId) public onlyShipper {
        require(_orderId <= orderCount && _orderId > 0, "Invalid order ID");
        require(orders[_orderId].status == Status.Created, "Order already processed");

        shipmentCount++;
        orders[_orderId].status = Status.InTransit;
        shipments[shipmentCount] = Shipment(shipmentCount, _orderId, msg.sender, Status.InTransit);
        emit ShipmentCreated(shipmentCount, _orderId, msg.sender);
    }
    function shipperVerification() public onlyShipper {
        ship_verify = true;
    }
    function customerVerification() public onlyCustomer {
        cust_verify = true;
    }
    function deliveryApproval() view public returns  (string memory)  {
        require((cust_verify) && (ship_verify), "Dual-verification failed");
        return "Delivery successfully completed";
    }
}
