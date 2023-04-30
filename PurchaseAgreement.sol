// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
contract PurchaseAgreement{
    uint public value;
    address payable public seller;
    address payable public buyer;
    enum State { Created, Locked, Release, Inactive}
    State public state;
    //constructor is invoked when the contract is being deployed...
    constructor () payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
    }
    /// The function can not be called at the current state
    error InvalidState();
    /// only the buyer can call this function
    error OnlyBuyer();
    /// only the seller can call this function
    error OnlySeller();
    modifier onlybuyer(){
        if(msg.sender != buyer){
            revert OnlyBuyer();
        }
        _;
    }
    modifier onlyseller(){
        if(msg.sender != seller){
            revert OnlySeller();
        }
        _;
    }
    modifier inState(State state_){
        if(state != state_){
            revert InvalidState();
        }
        _;
    }
    function confirmPurchase() external inState(State.Created) payable{
        // require(msg.value == (2 * value), "Please send 2 * the purchase amount"); -- works in remix ide
        buyer = payable(msg.sender);
        state = State.Locked;
    }
    function confirmReceived() external onlybuyer inState(State.Locked){
        state = State.Release;
        buyer.transfer(value); 
    }
    function paySeller() external onlyseller inState(State.Release){
        state = State.Inactive;
        seller.transfer(3*value);

    }
    function abort() external onlyseller {
        state = State.Inactive;
        seller.transfer(address(this).balance);

    }

}