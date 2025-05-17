defmodule HydepwnsLiveview.Resources.OrderResource do
  @moduledoc """
  Defines the Order resource for an e-commerce system.

  This resource represents a customer order in an e-commerce system,
  and uses the event-sourced pattern to track order state transitions.
  """

  use HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource, snapshot_interval: 100

  # Add alias for ResourceEventGenerator if it doesn't exist
  alias HydepwnsLiveview.Events.ResourceEventGenerator

  @doc """
  Returns the initial state for a new order.
  """
  @spec initial_state() :: HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.resource_state()
  @impl true
  def initial_state do
    %{
      status: "cart",
      items: [],
      customer_id: nil,
      shipping_address: nil,
      billing_address: nil,
      payment_method: nil,
      total_amount: Decimal.new("0.00"),
      tax_amount: Decimal.new("0.00"),
      shipping_amount: Decimal.new("0.00"),
      discount_amount: Decimal.new("0.00"),
      created_at: nil,
      updated_at: nil,
      fulfilled_at: nil,
      cancelled_at: nil
    }
  end

  @doc """
  Returns the type name for this resource.
  """
  @spec resource_type() :: String.t()
  @impl true
  def resource_type, do: "order"

  @doc """
  Applies an event to the order's state.
  """
  @spec apply_event(HydepwnsLiveview.Events.ResourceIntegration.EventSourcedResource.event(), map()) :: map()
  @impl true
  def apply_event(%Event{type: "order_created"} = event, _state) do
    # Initialize a new order
    state = initial_state()

    # Apply the event data
    Map.merge(state, %{
      customer_id: event.data.customer_id,
      created_at: event.data.created_at || DateTime.utc_now(),
      updated_at: event.data.created_at || DateTime.utc_now()
    })
  end

  def apply_event(%Event{type: "item_added"} = event, state) do
    item = event.data.item

    # Check if the item already exists
    existing_item_index =
      Enum.find_index(state.items, fn i -> i.product_id == item.product_id end)

    # Update or add the item
    updated_items =
      if existing_item_index do
        List.update_at(state.items, existing_item_index, fn existing ->
          %{existing | quantity: existing.quantity + item.quantity}
        end)
      else
        state.items ++ [item]
      end

    # Recalculate total
    total = calculate_total(updated_items)

    # Update state
    %{
      state
      | items: updated_items,
        total_amount: total,
        updated_at: event.data.updated_at || DateTime.utc_now()
    }
  end

  def apply_event(%Event{type: "item_removed"} = event, state) do
    product_id = event.data.product_id

    # Remove the item
    updated_items = Enum.filter(state.items, fn item -> item.product_id != product_id end)

    # Recalculate total
    total = calculate_total(updated_items)

    # Update state
    %{
      state
      | items: updated_items,
        total_amount: total,
        updated_at: event.data.updated_at || DateTime.utc_now()
    }
  end

  def apply_event(%Event{type: "item_quantity_updated"} = event, state) do
    product_id = event.data.product_id
    quantity = event.data.quantity

    # Update the item quantity
    updated_items =
      Enum.map(state.items, fn item ->
        if item.product_id == product_id do
          %{item | quantity: quantity}
        else
          item
        end
      end)

    # Recalculate total
    total = calculate_total(updated_items)

    # Update state
    %{
      state
      | items: updated_items,
        total_amount: total,
        updated_at: event.data.updated_at || DateTime.utc_now()
    }
  end

  def apply_event(%Event{type: "shipping_address_updated"} = event, state) do
    %{
      state
      | shipping_address: event.data.shipping_address,
        updated_at: event.data.updated_at || DateTime.utc_now()
    }
  end

  def apply_event(%Event{type: "billing_address_updated"} = event, state) do
    %{
      state
      | billing_address: event.data.billing_address,
        updated_at: event.data.updated_at || DateTime.utc_now()
    }
  end

  def apply_event(%Event{type: "payment_method_selected"} = event, state) do
    %{
      state
      | payment_method: event.data.payment_method,
        updated_at: event.data.updated_at || DateTime.utc_now()
    }
  end

  def apply_event(%Event{type: "order_submitted"} = event, state) do
    %{state | status: "submitted", updated_at: event.data.updated_at || DateTime.utc_now()}
  end

  def apply_event(%Event{type: "order_paid"} = event, state) do
    %{state | status: "paid", updated_at: event.data.updated_at || DateTime.utc_now()}
  end

  def apply_event(%Event{type: "order_shipped"} = event, state) do
    %{state | status: "shipped", updated_at: event.data.updated_at || DateTime.utc_now()}
  end

  def apply_event(%Event{type: "order_delivered"} = event, state) do
    %{state | status: "delivered", updated_at: event.data.updated_at || DateTime.utc_now()}
  end

  def apply_event(%Event{type: "order_fulfilled"} = event, state) do
    %{
      state
      | status: "fulfilled",
        fulfilled_at: event.data.fulfilled_at || DateTime.utc_now(),
        updated_at: event.data.updated_at || DateTime.utc_now()
    }
  end

  def apply_event(%Event{type: "order_cancelled"} = event, state) do
    %{
      state
      | status: "cancelled",
        cancelled_at: event.data.cancelled_at || DateTime.utc_now(),
        updated_at: event.data.updated_at || DateTime.utc_now()
    }
  end

  def apply_event(%Event{type: "discount_applied"} = event, state) do
    discount_amount = event.data.amount

    # Update total with discount
    updated_total = Decimal.sub(state.total_amount, discount_amount)

    %{
      state
      | discount_amount: discount_amount,
        total_amount: updated_total,
        updated_at: event.data.updated_at || DateTime.utc_now()
    }
  end

  # Catch-all for unknown events
  def apply_event(_event, state), do: state

  # Command handlers

  @doc """
  Handles a command and generates events based on the command type.
  """
  @spec handle_command(any(), map(), String.t()) :: {:ok, [HydepwnsLiveview.Events.Core.Event.t()]} | {:error, any()}
  @impl true
  def handle_command(command, _state, id) do
    case command do
      {:create_order, customer_id} ->
        {:ok,
         [
           %HydepwnsLiveview.Events.Core.Event{
             type: "order_created",
             resource_id: id,
             resource_type: resource_type(),
             data: %{
               customer_id: customer_id,
               created_at: DateTime.utc_now()
             }
           }
         ]}

      {:add_item, product_id, quantity, price} ->
        {:ok,
         [
           %HydepwnsLiveview.Events.Core.Event{
             type: "item_added",
             resource_id: id,
             resource_type: resource_type(),
             data: %{
               item: %{
                 product_id: product_id,
                 quantity: quantity,
                 price: price
               },
               updated_at: DateTime.utc_now()
             }
           }
         ]}

      _ ->
        {:error, :unknown_command}
    end
  end

  @doc """
  Creates a new order for a customer.

  ## Parameters
  * `resource_id` - The ID for the new order
  * `customer_id` - The customer ID
  * `metadata` - Additional metadata

  ## Returns
  * `{:ok, event}` - Order created successfully
  * `{:error, reason}` - Failed to create order
  """
  @spec create_order(String.t(), String.t(), map()) :: {:ok, HydepwnsLiveview.Events.Core.Event.t()} | {:error, any()}
  def create_order(resource_id, customer_id, metadata \\ %{}) do
    event = %Event{
      type: "order_created",
      resource_id: resource_id,
      data: %{
        customer_id: customer_id,
        created_at: DateTime.utc_now()
      },
      metadata: metadata
    }

    ResourceEventGenerator.generate_event(__MODULE__, event)
  end

  @doc """
  Adds an item to the order.

  ## Parameters
  * `resource_id` - The order ID
  * `product_id` - The product ID
  * `quantity` - Quantity to add
  * `price` - Unit price
  * `metadata` - Additional metadata

  ## Returns
  * `{:ok, event}` - Item added successfully
  * `{:error, reason}` - Failed to add item
  """
  @spec add_item(String.t(), String.t(), integer(), Decimal.t(), map()) :: {:ok, HydepwnsLiveview.Events.Core.Event.t()} | {:error, any()}
  def add_item(resource_id, product_id, quantity, price, metadata \\ %{}) do
    event = %Event{
      type: "item_added",
      resource_id: resource_id,
      data: %{
        item: %{
          product_id: product_id,
          quantity: quantity,
          unit_price: price,
          total_price: Decimal.mult(price, Decimal.new(quantity))
        },
        updated_at: DateTime.utc_now()
      },
      metadata: metadata
    }

    ResourceEventGenerator.generate_event(__MODULE__, event)
  end

  @doc """
  Removes an item from the order.

  ## Parameters
  * `resource_id` - The order ID
  * `product_id` - The product ID
  * `metadata` - Additional metadata

  ## Returns
  * `{:ok, event}` - Item removed successfully
  * `{:error, reason}` - Failed to remove item
  """
  @spec remove_item(String.t(), String.t(), map()) :: {:ok, HydepwnsLiveview.Events.Core.Event.t()} | {:error, any()}
  def remove_item(resource_id, product_id, metadata \\ %{}) do
    event = %Event{
      type: "item_removed",
      resource_id: resource_id,
      data: %{
        product_id: product_id,
        updated_at: DateTime.utc_now()
      },
      metadata: metadata
    }

    ResourceEventGenerator.generate_event(__MODULE__, event)
  end

  @doc """
  Updates the quantity of an item in the order.

  ## Parameters
  * `resource_id` - The order ID
  * `product_id` - The product ID
  * `quantity` - New quantity
  * `metadata` - Additional metadata

  ## Returns
  * `{:ok, event}` - Quantity updated successfully
  * `{:error, reason}` - Failed to update quantity
  """
  @spec update_item_quantity(String.t(), String.t(), integer(), map()) :: {:ok, HydepwnsLiveview.Events.Core.Event.t()} | {:error, any()}
  def update_item_quantity(resource_id, product_id, quantity, metadata \\ %{}) do
    event = %Event{
      type: "item_quantity_updated",
      resource_id: resource_id,
      data: %{
        product_id: product_id,
        quantity: quantity,
        updated_at: DateTime.utc_now()
      },
      metadata: metadata
    }

    ResourceEventGenerator.generate_event(__MODULE__, event)
  end

  @doc """
  Submits the order for processing.

  ## Parameters
  * `resource_id` - The order ID
  * `metadata` - Additional metadata

  ## Returns
  * `{:ok, event}` - Order submitted successfully
  * `{:error, reason}` - Failed to submit order
  """
  @spec submit_order(String.t(), map()) :: {:ok, HydepwnsLiveview.Events.Core.Event.t()} | {:error, any()}
  def submit_order(resource_id, metadata \\ %{}) do
    event = %Event{
      type: "order_submitted",
      resource_id: resource_id,
      data: %{
        updated_at: DateTime.utc_now()
      },
      metadata: metadata
    }

    ResourceEventGenerator.generate_event(__MODULE__, event)
  end

  # Private helper functions

  defp calculate_total(items) do
    Enum.reduce(items, Decimal.new("0.00"), fn item, acc ->
      item_total = Decimal.mult(item.unit_price, Decimal.new(item.quantity))
      Decimal.add(acc, item_total)
    end)
  end
end
