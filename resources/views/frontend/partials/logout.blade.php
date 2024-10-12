<div class="modal fade" id="confirmModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Log out or not</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body flex-box">
                <div class="flex-center">
                    <span>Are you sure to log out?</span>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="color-btn btn btn-secondary" data-dismiss="modal">
                    Cancel
                </button>
                <form method="POST" action="{{ route('frontend.logout') }}">
                    @csrf
                    <button type="submit">Logout</button>
                </form>
            </div>
        </div>
    </div>
</div>