import { configureStore, getDefaultMiddleware } from "@reduxjs/toolkit";
import { createStore } from "redux";
import { connectReducer } from './connectSlice'



export const store = configureStore({
    reducer: {
        connectReducer: connectReducer
    },
    middleware: getDefaultMiddleware({
        seriallizableCheck: false,
        immutableCheck: false
    })
})