import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import Web3 from 'web3'

const loadToken = createAsyncThunk(
    "LoadToken",
    async (data, thunkAPI) => {
        try {
            if (Web3.givenProvider) {
                const web3 = new Web3(Web3.givenProvider)
                await Web3.givenProvider.enable()
                const address = await web3.eth.getAccounts()

                console.log(address)
                return {
                    web3, address: address[0]
                }
            }
        } catch (error) {

        }
    }

)


const ApiTokenSlice = createSlice({
    name: "ApiTokenSlice",
    initialState: {
        address: null
    },
    reducers: {

    },
    extraReducers: {

    }
})