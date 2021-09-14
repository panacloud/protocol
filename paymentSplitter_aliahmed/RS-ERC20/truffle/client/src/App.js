import logo from './logo.svg';
import './App.css';
import { useDispatch, useSelector } from 'react-redux';
import { useEffect, useState } from 'react';
import { web3init, web3Reload } from './store/connectSlice';

function App() {
  const address = useSelector((state) => {
    return state.connectReducer.address
  })
  const accessMsg = useSelector((state) => {
    return state.connectReducer.msg
  })

  const [name, setName] = useState(null)
  const [email, setEmail] = useState(null)

  const web3 = useSelector((state) => {
    return state.connectReducer.web3
  })
  const dispatch = useDispatch()
  const signmsg = async () => {
    if (name != null && email != null) {
      return await web3.eth.personal.sign(web3.utils.utf8ToHex(name) + web3.utils.utf8ToHex(email), address, "test password!")
    }
  }
  useEffect(() => {
    dispatch(web3Reload())

  }, []);

  // const currentAccount = async () => {
  //   await web3.personal.sign(web3.fromUtf8("Hello from Toptal!"), web3.eth.coinbase, console.log);

  // }

  const connectWallet = () => {
    console.log("button")

    dispatch(web3init())
    console.log(address)

  }

  console.log(address)

  return (
    <div className="App">
      Address<br></br>
      {address}<br></br>
      {name}
      <label>Sign-Up Form</label>
      <div>
        Name <input type='text' onChange={(e) => {
          e.preventDefault()
          setName(e.target.value)
        }} required ></input>
      </div>
      <div>
        Email <input type='text' onChange={(e) => setEmail(e.target.value)} required ></input>
      </div>
      <button onClick={() => connectWallet()}>Connect</button>
      <button onClick={async () => signmsg()}>Sign</button><br></br>
      <div>{accessMsg}</div>



    </div >
  );
}

export default App;
