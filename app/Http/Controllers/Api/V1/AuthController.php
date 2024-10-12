<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function login()
    {
        return view('auth.login');
    }

    public function authenticate(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $credentials = $request->only('email', 'password');

        if (Auth::attempt($credentials, $request->filled('remember'))) {
            $request->session()->regenerate();

            if ($request->wantsJson()) {
                $user = User::where('email', $request->email)->first();
                $token = $user->createToken('auth_token')->plainTextToken;
                return response()->json([
                    'message' => 'You have been logged in',
                    'user' => $user,
                    'token' => $token,
                    'status' => 'success',
                ]);
            }

            return redirect()->intended('home');
        }

        if ($request->wantsJson()) {
            return response()->json([
                'message' => 'Invalid login details',
                'status' => 'error',
            ], 401);
        }

        return back()->withErrors([
            'email' => 'The provided credentials do not match our records.',
        ]);
    }

    public function logout(Request $request)
    {
        if (Auth::check()) {
            Auth::user()->tokens->each(function ($token, $key) {
                $token->delete();
            });
        }

        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        if ($request->wantsJson()) {
            return response()->json([
                'message' => 'You have been logged out',
                'status' => 'success',
            ]);
        }

        return redirect('/');
    }
}