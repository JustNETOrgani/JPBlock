pragma solidity ^0.4.19;
// A Smart Contract to allow for all Journals to run on the Blockchain.

// Adding Safe Math library to handle computations. 
library sfMath{
    // Adding SafeMath libray functionality for Addition.
    function addNums(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}
// Library ends. 

// Contract begins. 
contract JPBlock{
    using sfMath for *;
    enum paperState {Writing,Submitted, UnderReview, ReviseAndReSubmit,RevisedManuSubmitted, Accepted, Rejected, AlreadyPublished, Published} // Various states of paper.
    enum journalState {Onboarding,Activated,UpdatedDetails, Inactive} // States that journals can be. 
    // Structs to be used in the contract.
    struct authorPool{
        address authorAddress; // Address of the one submitting the paper.
        bytes32[] publishedPapers; // Published papers. These are restricted access.
        bytes32[] OApublishedPapers; // Published papers under Open Access.
        bytes32[] journalsPubUnder; // Various Names of Journals which author has published works.
        bytes32[] paperTitles; // Title of paper.
        uint256 authorNumOfPub; // Number of published papers of the author. 
        uint256 jVoteCount; // Number of voting done by the author for Journal regarding their reputation.  
    }
    struct paperPool{
        bytes32 paperTitle;   // Title of the paper.
        bytes32 paperHash;   // Hash of the paper;
        uint8 OAchoice; // Open Access Choice: 1 for OA, 0 for Restricted.
        bytes32 authorIDhashed; // ORCID can be used. 
        bytes32 authorsNamesHashed; // Hashed names of authors to track Papers and authors.
        address submittingAuthor; // Address of the submitting author. 
		bytes32 paperIPFShash; // IPFS hash of paper.
		bytes32 suppleFileIPFShash; // IPFS hash of supplementary file.
        address paperToJAdd; // Address of the Journal.
        bytes32 journalName;  // Name of Journal accepting the paper.
        paperState pState;   // State of the paper. 
    }
    struct jPool{
        bytes32 jName;
        address jAdd; // Hashed Address of the Journal.
        string jURL; // URL of the journal.
        journalState jState; // State of the journal.
        uint256 totalPublications; // To count publications by the Journal.
        uint8 jImpactFactor; // Impact Factor as stated by the Journal.
        bytes32 pubKey; // Public key of the Journal.
        uint priceForOAPublication; // Price for OA publication in Eth to be set by each Journal upon registration.
        uint priceForOtherPublication; // Price for non-OA publication in Eth to be set by each Journal upon registration.
        uint subPrice; // Price to be paid to get access to restricted publications. 
        uint256 reputationScore; // Accumulated score of the Journal based on user votes.
    }
    struct paymentCorner{
        bytes32 paperHash; // Hash of the paper accepted to be published.
        uint8 paidOrNot; // State of payment. 1 denotes paid, 0 otherwise. 
    }
    struct restrictedPaperToIPFS{
        address jAdd; // Address of the journal.
        bytes32 IPFShash; // IPFS hash of the encrypted file.
    }
    struct paperPaidUsers{
        address requester; // User who requests for a restricted paper.
        uint256 voteCount; // User vote count for Journal.
    }
    
    // Global state variables.
    bytes32[] public openAccessPublishedWorks; // This will hold all publications to be made open access.
    address[] internal addressesOfJournals;
    bytes32[] namesOfRegisteredJournals;
    // Public mappings.
    mapping (address => authorPool) public authorMap; //Mapping for authors. Also serves as link to Papers and Journals. 
    mapping (address => jPool) public jMap; //Mapping for authors.
    mapping (bytes32 => paperPool) public paperMap; //Mapping for authors.
    mapping (bytes32 => paymentCorner) public paymentStatus; //Mapping for paper payment.
    mapping (address => uint) internal balance;
    mapping (bytes32 => restrictedPaperToIPFS) public rpaperToIPFSlink; // TO perform lookup of encrypted file based on paperHash;
    mapping (address => paperPaidUsers) public paidUserForPaper; // To track users who made payment for restricted papers. 
    // Public states.
    paperState public stateOfPaper;
    journalState public stateOfJournal;
    
    // Events begin.
    event newJournalCreated(bytes32 jName, address jAddress, string jURL);
    event paperSubDetails(bytes32 paperTitle,address indexed submittingAuthor,string jURL);
    event journalRecSub(address indexed jAddress,bytes32 paperTitle,bytes32 paperHash,address submittingAuthor,bytes32 paperIPFShash, bytes32 suppleFileIPFShash,bytes32 userPubKey);
    event publishedOAPaper(bytes32 title,bytes32 paperIPFShash);
    event paymentMade(address source,bytes32 paperHash,address indexed to);
    event userRequestedPaper(bytes32 IPFShash,bytes32 userPUbKey,address indexed jAdd);
    event restrictedPaperPublished(bytes32 paperTitle,bytes32 paperIPFSHash,address indexed jAdd);
    event userRequestMet(bytes32 indexed paperIPFSHashReq,bytes32 perUserIPFSencryptedLink);
    event revisedAndReSubmittedManu(address indexed jAddress,bytes32 origPaperHash,bytes32 newPaperHash);
    event noticeOfRevision(address indexed submittingAuthor,bytes32 paperHash,bytes32 revisionNote);
    event noticeOfAcceptance(address indexed submittingAuthor,bytes32 paperHash,bytes32 jName);
    event rejectionNotice(address indexed submittingAuthor,bytes32 paperHash,bytes32 ipfsHashOfRejReason);
    // Events end.
    
    // Constructor for the contract.
    function JPBlock() public {
        stateOfPaper = paperState.Writing;
        stateOfJournal = journalState.Onboarding;
    }
    
    // Public Function to create new jounal.
    function createJournal(bytes32 jName,string memory jURL,uint8 jIF,uint jOAcost,uint jnOAcost,uint subPrice,bytes32 pubKey) public returns (bool){
        // Journal checks.
        require(jMap[msg.sender].jState ==journalState.Onboarding);
        jMap[msg.sender].jAdd  = msg.sender;
        jMap[msg.sender].jName = jName;
        jMap[msg.sender].jURL  = jURL;
        jMap[msg.sender].totalPublications  = 0;
        jMap[msg.sender].jImpactFactor      = jIF; 
        jMap[msg.sender].priceForOAPublication      = jOAcost;
        jMap[msg.sender].priceForOtherPublication   = jnOAcost; 
        jMap[msg.sender].subPrice   = subPrice;
        jMap[msg.sender].pubKey = pubKey;
        jMap[msg.sender].jState = journalState.Activated;
        addressesOfJournals.push(msg.sender);
        namesOfRegisteredJournals.push(jName);
        newJournalCreated(jName,msg.sender,jURL); // Emit event on Journal creation. 
        return true;
    }
    
    // Public function that users call to vote on the reputation of journals. 
    function voteUpJreputation(address jAdd) public returns (bool){
        require(verifyInclusiveness(jAdd,addressesOfJournals)==1); // Verify jAdd provided by user is a Journal.
        if(paidUserForPaper[msg.sender].requester == msg.sender){ // This checks whether the user has already made payment. 
            require(paidUserForPaper[msg.sender].voteCount <= addressesOfJournals.length); // User cannot vote above number of journals on JPBLOCK.
            jMap[jAdd].reputationScore = sfMath.addNums((jMap[jAdd].reputationScore),1);
            paidUserForPaper[msg.sender].voteCount = sfMath.addNums(paidUserForPaper[msg.sender].voteCount,1);
            return true;
        }
        else{
                require(authorMap[msg.sender].authorNumOfPub > 2);
                require(authorMap[msg.sender].jVoteCount <= addressesOfJournals.length);
                jMap[jAdd].reputationScore = sfMath.addNums((jMap[jAdd].reputationScore),1);
                authorMap[msg.sender].jVoteCount = sfMath.addNums((authorMap[msg.sender].jVoteCount),1);
                return true;
        }
    }
    
    // Function to run checks on Journals. 
    function verifyInclusiveness(address inputAddress, address[] addressesArray) internal pure returns (uint8){
        for(uint256 i = 0; i < addressesArray.length; i++){ // Journals accross the world are finite so still ok.
            if (addressesArray[i] == inputAddress){               
              return 1;
            }
         }      
        return 0;
        }
    
    // Public function to update existing journal.
    function updateJournalDetails(bytes32 jName, string memory jURL,uint8 jIF,uint jOAcost,uint jnOAcost,uint subPrice,bytes32 pubKey) public returns (bool){
        require(verifyInclusiveness(msg.sender,addressesOfJournals)==1); // Check msg.sender is a journal on JPBLOCK.
        // Journal checks.
        require(jMap[msg.sender].jState ==journalState.Activated || jMap[msg.sender].jState == journalState.UpdatedDetails); // This permits for multiple updates.
        jMap[msg.sender].jAdd  = msg.sender;
        jMap[msg.sender].jName = jName;
        jMap[msg.sender].jURL  = jURL;
        jMap[msg.sender].jImpactFactor = jIF;
        jMap[msg.sender].priceForOAPublication = jOAcost;
        jMap[msg.sender].priceForOtherPublication = jnOAcost;
        jMap[msg.sender].subPrice   = subPrice;
        jMap[msg.sender].pubKey = pubKey;
        jMap[msg.sender].jState = journalState.UpdatedDetails;
        return true;
    }
    
    // Public Journal to make Journal Inactive. Paper Submissions would not be accepted.
    function makeJournalInactive() public returns (uint8){
        uint8 prospectiveJstatus = verifyInclusiveness(msg.sender,addressesOfJournals);
        require(prospectiveJstatus == 1);
        // Journal checks. 
        require(jMap[msg.sender].jState ==journalState.Activated || jMap[msg.sender].jState == journalState.UpdatedDetails); // This permits for multiple updates.
        jMap[msg.sender].jState = journalState.Inactive;
        return 1;
    }
    
    // Public Journal to re-activate a Journal for paper submissions.
    function activateJournal() public returns (bool){
        uint8 prospectiveJstatus = verifyInclusiveness(msg.sender,addressesOfJournals);
        require(prospectiveJstatus == 1);
        // Journal checks.
        require(jMap[msg.sender].jState ==journalState.Inactive); // Journal should be in Inactive state for re-activation to happen.
        jMap[msg.sender].jState = journalState.Activated;
        return true;
    }
        
    
    // Function for paper submission. Anyone who wants to submit a paper can call this function. 
    function submitPaper(bytes32 hashOfOrigSubpaper,bytes32 paperHash,bytes32 paperIPFShash,bytes32 suppleFileIPFShash,bytes32 paperTitle,bytes32 authorIDhashed,bytes32 nameOfAuthorHashed, address jAdd, bytes32 jName, bytes32 authorPubKey, uint8 pubOption) public returns (bool)
        {   
        require(addressesOfJournals.length >= 1); // Journals should be registered on JPBLOCK to proceed.
            // Paper checks. 
            require(paperMap[paperHash].pState == paperState.Writing || paperMap[paperHash].pState == paperState.ReviseAndReSubmit || paperMap[paperHash].pState == paperState.Rejected); // Already submitted paper cannot be re-submitted. States changes would not be stored.
            require(jMap[jAdd].jState ==journalState.Activated || jMap[jAdd].jState == journalState.UpdatedDetails);
            // For a rejected paper, ensure it is not resubmitted to the same journal that rejected it.
                if(paperMap[paperHash].pState == paperState.Rejected){
                    require(paperMap[paperHash].paperToJAdd !=jAdd);
                }
                // Check jName on that address matches user's jName input for certainty.
                require(keccak256(jMap[jAdd].jName) == keccak256(jName)); // To be sure users have both the Address and name of the journal right.
                    paperMap[paperHash].paperToJAdd = jAdd;
                    paperMap[paperHash].journalName = jName;
                    paperMap[paperHash].paperHash = paperHash; 
					paperMap[paperHash].paperIPFShash = paperIPFShash;  
					paperMap[paperHash].suppleFileIPFShash = suppleFileIPFShash;
                    paperMap[paperHash].paperTitle = paperTitle; 
                    paperMap[paperHash].authorIDhashed = authorIDhashed;
                    paperMap[paperHash].authorsNamesHashed = nameOfAuthorHashed; 
                    paperMap[paperHash].submittingAuthor = msg.sender;
                    paperMap[paperHash].OAchoice = pubOption;
                    if(paperMap[hashOfOrigSubpaper].pState == paperState.ReviseAndReSubmit){
                        paperMap[hashOfOrigSubpaper].pState = paperState.Writing;
                        paperMap[paperHash].pState = paperState.RevisedManuSubmitted;
                        revisedAndReSubmittedManu(jMap[jAdd].jAdd,hashOfOrigSubpaper,paperHash); // Journals can subscribe to this event.
                    }
                    else{
                            paperMap[paperHash].pState = paperState.Submitted;
                    }
                    // Details about the author continues.
                    authorMap[msg.sender].authorAddress = msg.sender;
                    // Emit events.
                    paperSubDetails(paperMap[paperHash].paperTitle,msg.sender,jMap[jAdd].jURL);
                    journalRecSub(jAdd,paperTitle,paperHash,msg.sender,paperIPFShash,suppleFileIPFShash,authorPubKey);
                    return true;
    }
    
    // Function to push paper to the review stage. Only Journals can call this function. 
    function pushPaperForReview(bytes32 paperHash) public returns(bool){
        // Paper checks.
        require(paperMap[paperHash].pState == paperState.Submitted || paperMap[paperHash].pState == paperState.RevisedManuSubmitted); // Due to this require it is no longer necessary to require the state of the journal as it implies all clear with the Journal.
        require(paperMap[paperHash].paperToJAdd == msg.sender); // Only Journal submitted to can push to Review stage. 
        paperMap[paperHash].pState = paperState.UnderReview;
        return true;
    }
    
    // Function to push paper to the review stage. Only Journals can call this function. 
    function pushPaperForRevisionAndReSub(bytes32 paperHash,bytes32 IPFShashOfRevNote) public returns(bool){
        // Paper checks.
        require(paperMap[paperHash].pState == paperState.UnderReview); // Due to this require it is no longer necessary to require the state of the journal as it implies all clear with the Journal.
        require(paperMap[paperHash].paperToJAdd == msg.sender); // Only Journal submitted to can push to Review stage. 
        paperMap[paperHash].pState = paperState.ReviseAndReSubmit; 
        noticeOfRevision(paperMap[paperHash].submittingAuthor,paperHash,IPFShashOfRevNote);
        return true;
    }
    
    // Function to push paper to the acceptance stage. Only Journals can call this function. 
    function pushPaperForAcceptance(bytes32 paperHash) public returns(bool){
        // Paper checks.
        require(paperMap[paperHash].pState == paperState.UnderReview); // Only papers under review can be accepted for publication.
        require(paperMap[paperHash].paperToJAdd == msg.sender); // To ensure that only the Journal that changed the paper state to Submitted/UnderReview can push to Acceptance stage.
        paperMap[paperHash].pState = paperState.Accepted;
        noticeOfAcceptance(paperMap[paperHash].submittingAuthor,paperHash,paperMap[paperHash].journalName); // Authors can subscribe to this event so payment can later be made.
        return true;
    }
    
     // Function to push paper to the acceptance stage. Only Journals can call this function. 
    function pushPaperForRejection(bytes32 paperHash, bytes32 ipfsHashOfRejReason) public returns(bool){
        // Paper checks.
        require(paperMap[paperHash].pState == paperState.UnderReview); // Rejection can happen at these stages.
        require(paperMap[paperHash].paperToJAdd == msg.sender); // To ensure that only the Journal that changed the paper state to Submitted/UnderReview can Reject it..
        paperMap[paperHash].pState = paperState.Rejected; 
        rejectionNotice(paperMap[paperHash].submittingAuthor,paperHash,ipfsHashOfRejReason);
        return true;
    }
    
    // Function to check paper publication option. OAchoice
    function authorPublicationChoice(bytes32 paperHash) public view returns (uint8){
        // Check choice made by the submitting author.
        if(paperMap[paperHash].OAchoice==1){
            return 1;
        }
        else{
                return 0;
        }
    }
    
    // Function to be called by authors whose paper has been accepted for publication to make payment. 
    function payForPaperPublication(bytes32 paperHash, address jAdd, uint256 amountToPay) payable public returns (bool){
        require(paperMap[paperHash].pState == paperState.Accepted);
        require(paperMap[paperHash].paperToJAdd == jAdd); // Ensure the Address provided by user matches the journal that accepted it for publication.
        require(paymentStatus[paperHash].paidOrNot==0); // This prevents double payment.
        require(msg.value==amountToPay); // Only the exact amount can be paid.
        if(paperMap[paperHash].OAchoice==1){
            require(jMap[jAdd].priceForOAPublication == amountToPay); // Ensure amount being paid by user is same as the cost for publication set by the Journal.
            paymentStatus[paperHash].paidOrNot = 1;
            balance[msg.sender] -=msg.value; // Deduct amount to pay from msg.sender.
            address(jAdd).transfer(msg.value); // Transfer Eth to Journal.
            paymentMade(msg.sender,paperHash,jAdd);
            return true; 
        }
        else{
                require(jMap[jAdd].priceForOtherPublication == amountToPay); // Ensure amount being paid by user is same as the cost for publication set by the Journal.
                paymentStatus[paperHash].paidOrNot = 1;
                balance[msg.sender] -=msg.value; // Deduct amount to pay from msg.sender.
                address(jAdd).transfer(msg.value); // Transfer Eth to Journal.
                paymentMade(msg.sender,paperHash,jAdd);
                return true; 
        }
    }
    
    // Function to publish paper. This would be called by Journals only.
    function createPublication(address submittingAuthor, bytes32 paperTitle,bytes32 paperHashPrv,bytes32 paperHashNew,bytes32 paperIPFSHash) public returns (bool){
        // Paper checks.
        require(paymentStatus[paperHashPrv].paidOrNot==1); // Only paid papers gets published.
            require(paperMap[paperHashPrv].pState == paperState.Accepted); // Ensures that only that Journal that accepted it can publish it.
                require(paperMap[paperHashPrv].paperToJAdd==msg.sender);// Check that paper has been accepted for publication by the required Journal.
                    require(paperMap[paperHashPrv].paperHash == paperHashPrv);
                        require(authorMap[submittingAuthor].authorAddress == submittingAuthor);// Check that the address of the author who submitted the paper matches the submitting  author's address entered.
                            paperMap[paperHashNew].authorIDhashed       = paperMap[paperHashPrv].authorIDhashed;
                            paperMap[paperHashNew].authorsNamesHashed   = paperMap[paperHashPrv].authorsNamesHashed;
                            paperMap[paperHashNew].paperTitle   = paperTitle;   
                            paperMap[paperHashNew].paperHash    = paperHashNew; // Update Paper pool with the latest hash.
                            paperMap[paperHashNew].paperToJAdd  = msg.sender;  
                            paperMap[paperHashNew].journalName  = jMap[msg.sender].jName;
                            paperMap[paperHashNew].pState       = paperState.Published;
                            paperMap[paperHashPrv].pState       = paperState.AlreadyPublished;
                            // Author updates.
                            authorMap[submittingAuthor].authorNumOfPub = sfMath.addNums((authorMap[submittingAuthor].authorNumOfPub),1);
                            authorMap[submittingAuthor].paperTitles.push(paperTitle);
                            authorMap[submittingAuthor].publishedPapers.push(paperHashNew); // Track published papers. 
                            authorMap[submittingAuthor].journalsPubUnder.push(jMap[msg.sender].jName); // Track journals author woudl be publishing to.
                            // Journal updates.
                            jMap[msg.sender].totalPublications = sfMath.addNums((jMap[msg.sender].totalPublications),1);
                            // Open Access issues.
                            if(paperMap[paperHashPrv].OAchoice==1){ // Journal is publishing under Open Access.
                                openAccessPublishedWorks.push(paperIPFSHash); // IPFS hash is stored. 
                                authorMap[submittingAuthor].OApublishedPapers.push(paperIPFSHash);
                                publishedOAPaper(paperTitle,paperIPFSHash); // Event to announce the details of the published paper. 
                            }
                            else{
                                    rpaperToIPFSlink[paperIPFSHash].IPFShash = paperIPFSHash;
                                    rpaperToIPFSlink[paperIPFSHash].jAdd = msg.sender;
                                    restrictedPaperPublished(paperTitle,paperIPFSHash,msg.sender); // Users can subscribe to it based on their preferred Journal. 
                            }
                            return true;
        }
    
    // Function to pay and request for restricted paper.
    function payToGetRestrictedPaper(bytes32 paperIPFSHash, bytes32 userPUbKey, uint256 amountToPay) payable public returns (bool){
        require(msg.value==amountToPay); // Only the exact amount can be paid.
        require(jMap[rpaperToIPFSlink[paperIPFSHash].jAdd].subPrice == amountToPay); // Ensure amount being paid by user is same as the cost for publication set by the Journal.
        balance[msg.sender] -=msg.value; // Deduct amount to pay from msg.sender.
        rpaperToIPFSlink[paperIPFSHash].jAdd.transfer(amountToPay); // Transfer Eth to the Journal that published it.
        paidUserForPaper[msg.sender].requester = msg.sender;
        userRequestedPaper(rpaperToIPFSlink[paperIPFSHash].IPFShash,userPUbKey,rpaperToIPFSlink[paperIPFSHash].jAdd); // Jouranls subscribe to this as notification.
        return true;
    }
    
    // Function to make available paid paper to users by Journals.
    function sendToPaidUser(bytes32 paperIPFSHash,bytes32 perUserIPFSencryptedLink) public returns (bool){
        userRequestMet(paperIPFSHash,perUserIPFSencryptedLink); // Paid users can subscribe, filter based on the paperIPFSHash known and decrypt the IPFS file with their private key.
        return true;
        
    }
    
    // Function for Journals to get the total amount accrued on JPBlock.
    function getAmtAccrued() public view returns (uint8){
        require(jMap[msg.sender].jAdd == msg.sender); // Ensures that only members known to jMap can check their balance.
        return 1;
    }
    
    // Public function to retrieve author works.TODO.
    function retrieveAuthorWorks(address authorAddress) public view returns (uint256,bytes32[],bytes32[],uint256,bytes32[],bytes32[]){
        // Retrieve details based on Total publications and Hashes, Total Open Access publication and Hashes(Can be converted at front end) and Number of Restricted publications.
        return(authorMap[authorAddress].authorNumOfPub,authorMap[authorAddress].publishedPapers,authorMap[authorAddress].journalsPubUnder,authorMap[authorAddress].OApublishedPapers.length,authorMap[authorAddress].OApublishedPapers,authorMap[authorAddress].paperTitles);
    }
    
    // Getter functions begin.
    // Function to get details of all existing journals.
    function getRegisteredJournals() public view returns (uint256,address[],bytes32[]){
        return (addressesOfJournals.length,addressesOfJournals,namesOfRegisteredJournals);
    }
    
    // Function to get details of existing journals. 
    function getAjournalDetail(address jAdd) public view returns (bytes32,string,string,uint256,uint256,uint8,uint,uint,uint,bytes32){ 
        jPool memory jp = jMap[jAdd];
        if (jp.jState ==journalState.Activated || jp.jState == journalState.UpdatedDetails || jp.jState == journalState.Inactive){
            if (jp.jState == journalState.Activated){
                return(jp.jName,jp.jURL,'Journal is active',jp.reputationScore,jp.totalPublications,jp.jImpactFactor,jp.priceForOAPublication,jp.priceForOtherPublication,jp.subPrice,jp.pubKey);
            }
            if (jp.jState == journalState.UpdatedDetails){
                return(jp.jName,jp.jURL,'Details of Journal Updated.',jp.reputationScore,jp.totalPublications,jp.jImpactFactor,jp.priceForOAPublication,jp.priceForOtherPublication,jp.subPrice,jp.pubKey);
            }
            if (jp.jState == journalState.Inactive){
                return(jp.jName,jp.jURL,'Journal is Inactive',jp.reputationScore,jp.totalPublications,jp.jImpactFactor,jp.priceForOAPublication,jp.priceForOtherPublication,jp.subPrice,jp.pubKey);
            }
        }
        else{
                return("****","*****",'Sorry! No such Journal exist.',0,0,0,0,0,0,"****");
        }
    }
    
    // Public function for Open Access Publications.  
     function getOpenAccesspapers() public view returns (bytes32[]) {
        return openAccessPublishedWorks; // Can be handled at front end by conversion. For all Journals under Open Access.
    }
    
    // Public function to get count of Open Access publications. 
    function countOpenAccessPublications() public view returns (uint256) {
        return openAccessPublishedWorks.length;
    }
    // Getter functions end.
    
    // Tracking function begins. Anyone can call this function to track status of a paper.
    function checkPaperStatus(bytes32 paperHash,bytes32 authorsNamesHashed) public view returns (string,bytes32){
        paperPool memory pPool = paperMap[paperHash];
        if(pPool.pState==paperState.Submitted && pPool.authorsNamesHashed == authorsNamesHashed){ 
            return("Paper has been Submitted to: ",pPool.journalName);
        }
        if(pPool.pState==paperState.UnderReview && pPool.authorsNamesHashed == authorsNamesHashed){
            return("Paper is under review with: ",pPool.journalName); 
        }
        if(pPool.pState==paperState.ReviseAndReSubmit && pPool.authorsNamesHashed == authorsNamesHashed){
            return("Recommended for revision and re-submission by: ",pPool.journalName);
        }
        if(pPool.pState==paperState.RevisedManuSubmitted && pPool.authorsNamesHashed == authorsNamesHashed){
            return("Paper revised and resbumitted to: ",pPool.journalName);
        }
        if(pPool.pState==paperState.Accepted && pPool.authorsNamesHashed == authorsNamesHashed){
            return("Paper has been accepted for publication by: ",pPool.journalName);
        }
        if(pPool.pState==paperState.Published && pPool.authorsNamesHashed == authorsNamesHashed){
            return("Paper has been Published by: ",pPool.journalName);
        }
        if(pPool.pState==paperState.Rejected && pPool.authorsNamesHashed == authorsNamesHashed){
            return("Paper rejected by: ",pPool.journalName); 
        }
        else{
            return("****Sorry! Paper unknown to JPBlock","****");
        }
    }
    // Tracking function ends.
    
    // Function to prove authorship.
    function proveAuthorship(bytes32 paperHash,bytes32 paperTitle, bytes32 authorsNamesHashed, bytes32 authorIDhashed) public view returns (uint8){
        paperPool memory pMap = paperMap[paperHash];
        // Check inputs against SC data.
        if(pMap.paperHash==paperHash && pMap.authorsNamesHashed == authorsNamesHashed && pMap.paperTitle==paperTitle && pMap.authorIDhashed == authorIDhashed){
            if(pMap.pState==paperState.Published){
                return 1;
                }
            if(pMap.pState==paperState.Accepted){
                return 2;
                }
            if(pMap.pState==paperState.UnderReview){
                return 3;
                }
            if(pMap.pState==paperState.Submitted){
                return 4;
                }
            if(pMap.pState==paperState.Rejected){
                return 5;
                } 
            if(pMap.pState==paperState.ReviseAndReSubmit){
                return 6;
                }
            if(pMap.pState==paperState.RevisedManuSubmitted){
                return 7;
                }
        }
        // Failed proof.
        else{
                return 0;
        }
    }
}