import Web3 from "web3";
import ABI from "./ABI.json";

const CONTRACT_ADDRESS = "0xd25C7236149d878a0A00c8eBeDeaAB70991Bc767";
const OPTIMISM_TESTNET_CHAIN_ID = '0x1A4';

export async function doLogin() {
    if (!window.ethereum) throw new Error("No MetaMask found!");

    const web3 = new Web3(window.ethereum);
    const accounts = await web3.eth.requestAccounts();
    if (!accounts || !accounts.length) throw new Error("Wallet not found/allowed.");

    // Check if connected network is Optimism Testnet
    const chainId = await web3.eth.getChainId();
    if (chainId !== parseInt(OPTIMISM_TESTNET_CHAIN_ID, 16)) {
        try {
            // Request to switch to Optimism Testnet
            await window.ethereum.request({
                method: 'wallet_switchEthereumChain',
                params: [{ chainId: OPTIMISM_TESTNET_CHAIN_ID }],
            });
        } catch (switchError) {
            // This error code indicates that the chain has not been added to MetaMask.
            if (switchError.code === 4902) {
                try {
                    // Request to add Optimism Testnet to MetaMask
                    await window.ethereum.request({
                        method: 'wallet_addEthereumChain',
                        params: [
                            {
                                chainId: OPTIMISM_TESTNET_CHAIN_ID,
                                rpcUrl: 'https://goerli.optimism.io/', // This is an example URL, make sure to use the correct one for Optimism Testnet
                            },
                        ],
                    });
                } catch (addError) {
                    // Handle errors when adding the chain fails
                    throw new Error("Failed to add Optimism Testnet to MetaMask.");
                }
            } else {
                // Handle other errors when switching the chain fails
                throw new Error("Failed to switch to Optimism Testnet.");
            }
        }
    }

    localStorage.setItem("wallet", accounts[0]);
    return accounts[0];
}

function getContract() {
    const web3 = new Web3(window.ethereum);
    const from = localStorage.getItem("wallet");
    return new web3.eth.Contract(ABI, CONTRACT_ADDRESS, { from });
}

export function addCampaign(campaign) {
    const contract = getContract();
    return contract.methods.addCampaign(campaign.title, campaign.description, campaign.videoUrl, campaign.imageUrl).send();
}

export function getLastCampaignId() {
    const contract = getContract();
    return contract.methods.nextId().call();
}

export function getCampaign(id) {
    const contract = getContract();
    return contract.methods.campaigns(id).call();
}

export function donate(id, donation) {
    const contract = getContract();
    return contract.methods.donate(id).send({ value: Web3.utils.toWei(donation, "ether") });
}