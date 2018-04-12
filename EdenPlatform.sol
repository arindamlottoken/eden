pragma solidity ^0.4.13;

import "zeppelin-solidity/contracts/token/StandardToken.sol";

contract EdenPlatform {


struct one_account {
    address account_owner;
    address recovery_account;
    address veto_address;
    bytes32 phone_number_of_account_owner; 
    bytes32 email_id_of_account_owner; 
    string key_info;
    bool veto_flag;
    bool account_exists;
    bool recovery_timer_active;
    uint timeout;
    uint ether_balance;
}


mapping (address => one_account) public all_accounts;
mapping (bytes32 => address) phone2addr;
mapping (bytes32 => address) emailaddr2addr;

function add_phone_number(bytes32 input_phone_number_of_account_owner) public
{
	require( true == all_accounts[msg.sender].account_exists);
	if(input_phone_number_of_account_owner != 0)	
	{
		if(phone2addr[input_phone_number_of_account_owner] == 0)
		{
			phone2addr[all_accounts[msg.sender].phone_number_of_account_owner] = 0;
			all_accounts[msg.sender].phone_number_of_account_owner = input_phone_number_of_account_owner;
			phone2addr[input_phone_number_of_account_owner] = msg.sender;
		}
	}
}

function add_email_addr(bytes32 input_email_id_of_account_owner) public
{
	require( true == all_accounts[msg.sender].account_exists);
	if(input_email_id_of_account_owner != 0)
	{
		if(emailaddr2addr[input_email_id_of_account_owner] == 0)
		{
			emailaddr2addr[all_accounts[msg.sender].email_id_of_account_owner] = 0;
			all_accounts[msg.sender].email_id_of_account_owner = input_email_id_of_account_owner;
			emailaddr2addr[input_email_id_of_account_owner] = msg.sender;
		}
	}
}

function add_veto_addr(address input_veto_address) public
{
	require( true == all_accounts[msg.sender].account_exists);
	all_accounts[msg.sender].veto_address = input_veto_address;
}

function secure_account_big(
    address input_recovery_account,
    bytes32 input_phone_number_of_account_owner,
    bytes32 input_email_id_of_account_owner,
    string input_key_info,
    uint input_timeout,
    address input_veto_address
) public payable
{

    require( false == all_accounts[msg.sender].account_exists);
    //require( "" != key_info);
    //require( input_assets > 0);

    all_accounts[msg.sender].account_owner = msg.sender;
    all_accounts[msg.sender].key_info = input_key_info;
    all_accounts[msg.sender].recovery_account = input_recovery_account;
    all_accounts[msg.sender].timeout = input_timeout;
    all_accounts[msg.sender].veto_address = input_veto_address;
    all_accounts[msg.sender].recovery_timer_active = false;

    if(input_phone_number_of_account_owner != 0)   
    {
        if(phone2addr[input_phone_number_of_account_owner] == 0)
        {
            all_accounts[msg.sender].phone_number_of_account_owner = input_phone_number_of_account_owner;
            phone2addr[input_phone_number_of_account_owner] = msg.sender;
        }
    }
    if(input_email_id_of_account_owner != 0)
    {
        if(emailaddr2addr[input_email_id_of_account_owner] == 0)
        {
            all_accounts[msg.sender].email_id_of_account_owner = input_email_id_of_account_owner;
            emailaddr2addr[input_email_id_of_account_owner] = msg.sender;
        }
    }

    all_accounts[msg.sender].ether_balance += msg.value;
    all_accounts[msg.sender].account_exists = true;

}

function secure_account(
    address input_recovery_account,
    string input_key_info
) public payable
{

	require( false == all_accounts[msg.sender].account_exists);
	//require( "" != key_info);
	//require( input_assets > 0);

	all_accounts[msg.sender].account_owner = msg.sender; 
	all_accounts[msg.sender].key_info = input_key_info;
	all_accounts[msg.sender].recovery_account = input_recovery_account;
	all_accounts[msg.sender].timeout = 1;
	all_accounts[msg.sender].ether_balance += msg.value;
	all_accounts[msg.sender].account_exists = true;

}

function set_veto_for_account() public
{
	//require( true == all_accounts[msg.sender].account_exists);
	require( msg.sender == all_accounts[msg.sender].account_owner );
	all_accounts[msg.sender].veto_flag = true;
}


function cancel_veto_for_account(address account_owner) public
{
	//require( true == all_accounts[msg.sender].account_exists);
	require( msg.sender == all_accounts[account_owner].veto_address );
	all_accounts[account_owner].veto_flag = false;

}

function get_original_wallet_address_by_phone(bytes32 phone) public constant returns (address)
{
	if(phone2addr[phone] != 0)
		return phone2addr[phone];
}

function get_original_wallet_address_by_email(bytes32 email) public constant returns (address)
{
	if(emailaddr2addr[email] != 0)
		return emailaddr2addr[email];
}


function get_recovery_key_info_by_phone(bytes32 phone) public constant returns (string)
{
	if(phone2addr[phone] != 0)
		return all_accounts[phone2addr[phone]].key_info;

}

function get_recovery_key_info_by_email(bytes32 email) public constant returns (string)
{
	if(emailaddr2addr[email] != 0)
		return all_accounts[emailaddr2addr[email]].key_info;

}


function get_recovery_key_info_by_original_address(address account_address) public constant returns (string)
{
	if(true == all_accounts[account_address].account_exists )
		return all_accounts[account_address].key_info;

}


function get_recovery_address_by_original_address(address account_address) public constant returns (address)
{
	if(true == all_accounts[account_address].account_exists )
		return all_accounts[account_address].recovery_account;

}

function cancel_account_call_after_recover(address account_address) public
{

	require( true == all_accounts[account_address].account_exists);
        require( msg.sender == all_accounts[account_address].recovery_account );
        require( account_address == all_accounts[account_address].account_owner );

	all_accounts[account_address].account_exists = false;
	phone2addr[all_accounts[account_address].phone_number_of_account_owner] = 0;
	emailaddr2addr[all_accounts[account_address].email_id_of_account_owner] = 0;

	all_accounts[account_address].veto_flag = false;
	all_accounts[account_address].account_owner = 0; 
	all_accounts[account_address].recovery_account = 0; 
	all_accounts[account_address].phone_number_of_account_owner = "";
	all_accounts[account_address].email_id_of_account_owner = "";
	all_accounts[account_address].key_info = "";
	all_accounts[account_address].timeout = 0;
	all_accounts[account_address].ether_balance = 0;
	all_accounts[account_address].recovery_timer_active = false;
}


function cancel_account() public
{
	require( true == all_accounts[msg.sender].account_exists);
	require( msg.sender == all_accounts[msg.sender].account_owner );

	all_accounts[msg.sender].account_exists = false;
	phone2addr[all_accounts[msg.sender].phone_number_of_account_owner] = 0;
	emailaddr2addr[all_accounts[msg.sender].email_id_of_account_owner] = 0;

	if (all_accounts[msg.sender].ether_balance >0)  {

		msg.sender.transfer(all_accounts[msg.sender].ether_balance);
	        all_accounts[msg.sender].ether_balance=0;	
	}

	all_accounts[msg.sender].veto_flag = false;
	all_accounts[msg.sender].account_owner = 0; 
	all_accounts[msg.sender].recovery_account = 0; 
	all_accounts[msg.sender].phone_number_of_account_owner = "";
	all_accounts[msg.sender].email_id_of_account_owner = "";
	all_accounts[msg.sender].key_info = "";
	all_accounts[msg.sender].timeout = 1;
	all_accounts[msg.sender].ether_balance = 0;
	all_accounts[msg.sender].recovery_timer_active = false;
}

function remove_me_show_allowance(StandardToken token, address account, address spender) public constant returns (uint)
{
		return token.allowance(account, spender);
} 


function recover_account_end_tokens(address account_address, StandardToken token) public returns (string key_info)
{
	require( msg.sender == all_accounts[account_address].recovery_account );
	require( account_address == all_accounts[account_address].account_owner );

	if(true == all_accounts[account_address].veto_flag)
	{
		return("Call 1-800-EDENPLT to clear veto flag");
	}
	else {
	if (( all_accounts[account_address].recovery_timer_active == true) &&
	(now > all_accounts[account_address].timeout))  {

		token.transferFrom(account_address, 
		msg.sender,
		token.allowance(account_address, this));

	}
	else return("Not yet timed out. Try again later ... ");
	}
}


function recover_account_end_ether(address account_address) public returns (string key_info)
{
	require( msg.sender == all_accounts[account_address].recovery_account );
	require( account_address == all_accounts[account_address].account_owner );

	if(true == all_accounts[account_address].veto_flag)
	{
		return("Call 1-800-EDENPLT to clear veto flag");
	}
	else {
	if (( all_accounts[account_address].recovery_timer_active == true) &&
	(now > all_accounts[account_address].timeout) &&
	 ( all_accounts[account_address].ether_balance>0))  {

		msg.sender.transfer(all_accounts[account_address].ether_balance);
	        all_accounts[account_address].ether_balance=0;	
		all_accounts[account_address].recovery_timer_active=false;
		return("ether transferred");
	}
	else return("Not yet timed out. Try again later ... ");
	}
}


function recover_account_begin(address account_address) public returns (string key_info)
{
	//require( true == all_accounts[account_address].account_exists);
	require( msg.sender == all_accounts[account_address].recovery_account );
	require( account_address == all_accounts[account_address].account_owner );

	if(true == all_accounts[account_address].veto_flag)
	{
		return("Call 1-800-EDENPLT to clear veto flag");
	}
	else 
	{
		if( false == all_accounts[account_address].recovery_timer_active)
		{
			all_accounts[account_address].timeout = now + all_accounts[account_address].timeout;
			all_accounts[account_address].recovery_timer_active=true;
		}
	} 
}

function () public payable
{
	require(true == all_accounts[msg.sender].account_exists);
	all_accounts[msg.sender].ether_balance += msg.value;
}

function remove_some_ether (uint take) public
{
	require(true == all_accounts[msg.sender].account_exists);
	require(take <= all_accounts[msg.sender].ether_balance);
	msg.sender.transfer(take);
	all_accounts[msg.sender].ether_balance -= take;
}

}

