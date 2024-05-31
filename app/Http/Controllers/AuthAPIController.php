<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Request;

class AuthAPIController extends Controller
{
    // POST [name, password]
    public function login(Request $request)
    {
        // Validation
        $validator = Validator::make($request -> all(),[
            'name' => 'required|string',
            'password' => 'required'
        ]);

        // Return validation errors on failure
        if ($validator -> fails()) {
            $errors = $validator -> errors() -> messages();
            return response() -> json([
                'message' => 'The given data was invalid.',
                'errors' => $errors,
            ], 422);
        }

        // user data check by name
        $user = User::where('name', $request -> name) -> first();
        if (!empty($user)) {
            // user data exists

            // Password Check
            if (Hash::check($request -> password, $user -> password)) {
                // Password matched

                // Auth Token
                $token = $user -> createToken("mytoken") -> plainTextToken;
                return response() -> json([
                    'status' => true,
                    'message' => 'User logged in',
                    'token' => $token,
                    'data' => []
                ]);
            }
            else {
                // Password not matched
                return response() -> json([
                    'status' => false,
                    'message' => 'Invalid password',
                    'data' => []
                ], 422);
            }
        }
        else {
            // user data not exists
            return response() -> json([
                'status' => false,
                'message' => "Username doesn't match with records",
                'data' => []
            ], 422);
        }
    }

    // GET [Auth: Token]
    public function logout()
    {
        if (auth() -> user() -> tokens() -> delete()) {
            return response() -> json([
                'status' => true,
                'message' => 'User logged out',
                'data' => []
            ]);
        }
        else {
            return response() -> json([
                'status' => false,
                'message' => 'User logged out failed',
                'data' => []
            ], 401);
        }
    }

    // POST [name, full_name, email, password]
    public function register(Request $request)
    {
        // Validation
        $validator = Validator::make($request -> all(),[
            'name' => 'required|string|unique:users',
            'full_name' => 'required|string',
            'email' => 'required|string|email|unique:users',
            'password' => 'required|confirmed'
        ]);

        // Return validation errors on failure
        if ($validator -> fails()) {
            $errors = $validator -> errors() -> messages();
            return response() -> json([
                'message' => 'The given data was invalid.',
                'errors' => $errors,
            ], 422);
        }

        // Save Account
        User::create([
            'name' => $request -> name,
            'full_name' => $request -> full_name,
            'email' => $request -> email,
            'password' => bcrypt($request -> password),
            'user_type' => 'public'
        ]);

        return response() -> json([
            'status' => true,
            'message' => 'User registered successfully',
            'data' => []
        ]);
    }

    // GET [Auth: Token]
    public function profile(Request $request)
    {
        $user = $request->user(); // Retrieve authenticated user using Sanctum

        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'Unauthorized',
            ], 401);
        }

        return response()->json([
            'status' => true,
            'message' => 'Profile Information',
            'data' => $user, // Return user data
        ]);
    }

    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
