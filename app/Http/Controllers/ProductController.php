<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $products = Product::all();
        return response()->json($products);
    }

    // POST /products
    public function store(Request $request)
    {
        $request->validate([
            'name'        => 'required|string',
            'description' => 'nullable|string',
            'price'       => 'required|numeric',
            'quantity'    => 'required|integer',
        ]);

        $product = Product::create($request->all());
        return response()->json($product, 201);
    }

    // GET /products/{id}
    public function show($id)
    {
        $product = Product::findOrFail($id);
        return response()->json($product);
    }

    // PUT /products/{id}
    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $product->update($request->all());
        return response()->json($product);
    }

    // DELETE /products/{id}
    public function destroy($id)
    {
        Product::findOrFail($id)->delete();
        return response()->json(['message' => 'Product deleted successfully']);
    }
}
