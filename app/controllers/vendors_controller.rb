class VendorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_vendor, only: [:show, :edit, :update, :destroy]

  def index
    @vendors = current_user.vendors
  end

  def show
  end

  def new
    @vendor = current_user.vendors.build
  end

  def create
    @vendor = current_user.vendors.build(vendor_params)
    if @vendor.save
      redirect_to @vendor, notice: 'Vendor was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vendor.update(vendor_params)
      redirect_to @vendor, notice: 'Vendor was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vendor.destroy
    redirect_to vendors_url, notice: 'Vendor was successfully deleted.'
  end

  private

  def set_vendor
    @vendor = current_user.vendors.find(params[:id])
  end

  def vendor_params
    params.require(:vendor).permit(:name, :address, :phone, :email, :tax_identifier)
  end
end
