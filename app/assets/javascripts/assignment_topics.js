const enableBiddingCheckbox = document.getElementById('enable-bidding-checkbox');
  const biddingButton = document.getElementById('bidding-button');

  enableBiddingCheckbox.addEventListener('change', function() {
    biddingButton.style.display = enableBiddingCheckbox.checked ? 'inline-block' : 'none';
  });