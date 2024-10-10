<?php
namespace App\Http\Controllers\Frontend;

use App\Http\Controllers\Controller;
use App\Jobs\ClearCacheJob;
use App\Models\Log;
use App\Models\User;
use App\Models\UserProfile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login()
    {
        ClearCacheJob::dispatch();
        
        if (Auth::check()) {
            return redirect()->intended(route('frontend.home'));
        }
        
        return view('auth.login');
    }

    public function authenticate(Request $request)
    {
        try {
            $credentials = $request->validate([
                'email' => 'required|email',
                'password' => 'required',
            ]);

            $remember = $request->has('remember');

            if (Auth::attempt($credentials, $remember)) {
                $request->session()->regenerate();
                
                Log::create([
                    'user_id' => Auth::id(),
                    'login_time' => now()->format('H:i:s'),
                ]);

                return redirect()->intended(route('frontend.home'));
            }

            throw ValidationException::withMessages([
                'email' => __('The provided credentials do not match our records.'),
            ]);
        } catch (\Exception $e) {
            return back()->withErrors([
                'email' => $e->getMessage(),
            ])->withInput($request->only('email'));
        }
    }

    public function register(Request $request)
    {
        try {
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users',
                'password' => 'required|min:8',
            ]);

            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
            ]);

            $username = explode('@', $validated['email'])[0];
            
            UserProfile::create([
                'user_id' => $user->id,
                'username' => $username,
            ]);

            $user->assignRole(2);
            
            ClearCacheJob::dispatch();
            
            Auth::login($user);
            
            Log::create([
                'user_id' => Auth::id(),
                'login_time' => now()->format('H:i:s'),
            ]);

            return redirect()->route('frontend.main');
        } catch (\Exception $e) {
            return back()->withErrors([
                'email' => $e->getMessage(),
            ])->withInput($request->except('password'));
        }
    }

    public function logout(Request $request)
    {
        Auth::logout();
        
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        
        return redirect()->route('frontend.main');
    }
}