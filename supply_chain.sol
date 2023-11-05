// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    enum Status { Created, InTransit, Delivered }

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

    mapping(uint => Product) public products;
    mapping(uint => Order) public orders;
    mapping(uint => Shipment) public shipments;

    uint public productCount;
    uint public orderCount;
    uint public shipmentCount;

    event ProductCreated(uint productId, string productName, uint quantity);
    event OrderCreated(uint orderId, uint productId, uint quantity, address buyer);
    event ShipmentCreated(uint shipmentId, uint orderId, address logisticsProvider);

    function createProduct(string memory _productName, uint _quantity) public {
        productCount++;
        products[productCount] = Product(productCount, _productName, _quantity);
        emit ProductCreated(productCount, _productName, _quantity);
    }

    function createOrder(uint _productId, uint _quantity) public {
        require(_productId <= productCount && _productId > 0, "Invalid product ID");
        require(products[_productId].quantity >= _quantity, "Insufficient product quantity");

        orderCount++;
        products[_productId].quantity -= _quantity;
        orders[orderCount] = Order(orderCount, _productId, _quantity, msg.sender, Status.Created);
        emit OrderCreated(orderCount, _productId, _quantity, msg.sender);
    }

    function createShipment(uint _orderId) public {
        require(_orderId <= orderCount && _orderId > 0, "Invalid order ID");
        require(orders[_orderId].status == Status.Created, "Order already processed");

        shipmentCount++;
        orders[_orderId].status = Status.InTransit;
        shipments[shipmentCount] = Shipment(shipmentCount, _orderId, msg.sender, Status.InTransit);
        emit ShipmentCreated(shipmentCount, _orderId, msg.sender);
    }

    function deliveryApproval() public{
        
    }
}
