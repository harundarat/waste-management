// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";

contract WasteManagement is Ownable {

    enum WasteType {ORGANIC, ANORGANIC, RESIDUE}

    struct WasteDetail {
        uint256 arrivalDate;
        WasteType wasteType;
        string location;
        uint256 weight;
    }

    struct WasteStorageDetail {
        uint256 stored;
        uint256 transformed;
        uint256 movedOut;
    }

    mapping (uint256 => WasteDetail) wasteList;
    mapping (WasteType => WasteStorageDetail) wasteStorage;

    uint256 wasteCounter;

    event WasteAdded(uint256 _timestamp, uint256 _id, WasteType _wasteType, string _location, uint256 _weight);
    event WasteTreatment(uint256 _timestamp, uint256 _weight, WasteType _wasteType, string _wasteForm);
    event WasteMoved(uint256 _timestamp, uint256 _weight, string _wasteForm, string _wasteMoved);

    modifier doesExceed(uint256 target, uint256 available) {
        require(target < available, "Target waste exceed the available waste in the storage");
        _;
    }

    constructor(address initialOwner) Ownable(initialOwner) {}

    // Add Waste
    function addWaste(WasteType _wasteType, string calldata _location, uint256 _weight) public onlyOwner() {
        uint256 _timestamp = block.timestamp;
        uint256 _counter = wasteCounter;

        wasteList[_counter] = WasteDetail({
            arrivalDate: _timestamp,
            wasteType: _wasteType,
            location: _location,
            weight: _weight
        });

        wasteCounter++;

        wasteStorage[_wasteType].stored += _weight;

        emit WasteAdded(_timestamp, _counter, _wasteType, _location, _weight);

    }

    //Waste Treatment
    function wasteTreatment(WasteType _wasteType, uint256 _weight) public onlyOwner() doesExceed(_weight, wasteStorage[_wasteType].stored) {

        string memory _wasteForm;

        if (_wasteType == WasteType.ORGANIC) {
            wasteStorage[_wasteType].stored -= _weight;
            wasteStorage[_wasteType].transformed += _weight;
            _wasteForm = "Composted";
        } else if (_wasteType == WasteType.ANORGANIC) {
            wasteStorage[_wasteType].stored -= _weight;
            wasteStorage[_wasteType].transformed += _weight;
            _wasteForm = "Recycled";
        } else {
            wasteStorage[_wasteType].stored -= _weight;
            wasteStorage[_wasteType].transformed += _weight;
            _wasteForm = "Destroyed";
        }

        emit WasteTreatment(block.timestamp,_weight, _wasteType, _wasteForm);
    }

    //Move Waste
    function moveWaste(WasteType _wasteType, uint256 _weight) public  onlyOwner() doesExceed(_weight, wasteStorage[_wasteType].transformed){

        string memory _wasteForm;
        string memory _wasteMoved;

            wasteStorage[_wasteType].transformed -= _weight;
            wasteStorage[_wasteType].movedOut += _weight;
        
        if (_wasteType == WasteType.ORGANIC ) {
            _wasteForm = "Compost";
            _wasteMoved = "Distributed";
        } else if (_wasteType == WasteType.ANORGANIC) {
            _wasteForm = "Recycled";
            _wasteMoved = "Distributed";
        } else if (_wasteType == WasteType.RESIDUE) {
            _wasteForm = "Destroyed";
            _wasteMoved = "Disposed";
        }

        emit WasteMoved(block.timestamp, _weight, _wasteForm, _wasteMoved);
    }

    //Get Waste Data
    function getWaste(uint256 _id) public view returns(WasteDetail memory) {
        return wasteList[_id];
    }

    //Get Waste Storage
    function getWasteStorage(WasteType _wasteType) public view returns(WasteStorageDetail memory) {
        return wasteStorage[_wasteType];
    }

}