<form method="POST" action="{{ secure_url('authenticate') }}" class="login-form">
    @csrf
    
    <div class="form-group">
        <label for="email">Email</label>
        <input type="email" 
               name="email" 
               id="email" 
               value="{{ old('email') }}" 
               required 
               autocomplete="email" 
               autofocus>
        @error('email')
            <span class="error">{{ $message }}</span>
        @enderror
    </div>

    <div class="form-group">
        <label for="password">Password</label>
        <input type="password" 
               name="password" 
               id="password" 
               required 
               autocomplete="current-password">
        @error('password')
            <span class="error">{{ $message }}</span>
        @enderror
    </div>

    <div class="form-group">
        <label>
            <input type="checkbox" name="remember" {{ old('remember') ? 'checked' : '' }}>
            Remember me
        </label>
    </div>

    <button type="submit">Login</button>
</form>