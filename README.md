# Smart Contract Datasets of sGuard+
The repository consists of three datasets: Unlabled Real-world Smart Contract Dataset (URD), Labled Real-world Smart Contract Dataset (LRD), Publicly Available Smart Contract Vulnerability Dataset (PVD), which are used to train machine learning models of sGuard+ and evaluate the effectiveness and efficiency of sGuard+.
Labels in these datasets involve the following five vulnerabilities:
- <a  href ="https://swcregistry.io/docs/SWC-101">SWC-101</a>: Integer Overflow and Underflow Vulnerability (IOU)
- <a  href ="https://swcregistry.io/docs/SWC-104">SWC-104</a>: Unchecked Call Return Value Vulnerability (UCR)
- <a  href ="https://swcregistry.io/docs/SWC-106">SWC-106</a>: Unprotected SELFDESTRUCT Instruction Vulnerability (USI)
- <a  href ="https://swcregistry.io/docs/SWC-107">SWC-107</a>: Reentrancy Vulnerability (REN)
- <a  href ="https://swcregistry.io/docs/SWC-115">SWC-115</a>: Authorization through Tx-origin Vulnerability (TXO)

### Unlabled Real-world Smart Contract Dataset (URD)
> https://github.com/renardbebe/Smart-Contract-Benchmark-Suites/tree/master/dataset/UR


### Labled Real-world Smart Contract Dataset (LRD)
We label URD by manually confirming the detection results of <a  href ="https://github.com/crytic/slither">Slither</a>, <a  href ="https://github.com/eth-sri/securify">Securify</a> (and <a  href ="https://github.com/eth-sri/securify2">v2.0</a>) and <a  href ="https://github.com/ConsenSys/mythril">Mythril</a>.

### Publicly Available Smart Contract Vulnerability Dataset (PVD)
We collect the vulnerable smart contracts from <a  href ="https://swcregistry.io/">SWC Registry</a>, <a  href ="https://cve.mitre.org/">CVE</a>, and <a  href ="https://github.com/smartbugs/smartbugs/tree/master/dataset">SmartBugs Curated</a> as a ground truth of the five vulnerabilities mentioned above.

### SCRepair Dataset (SCRD)
> https://github.com/xiaoly8/SCRepair
