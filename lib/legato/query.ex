defmodule Legato.Query do
  defstruct profile: nil,
            view_id: nil,
            metrics: [],
            dimensions: [],
            date_ranges: [],
            order_bys: [],
            filters: %{
              metrics: %Legato.Query.FilterSet{as: :metrics},
              dimensions: %Legato.Query.FilterSet{as: :dimensions}
            },
            segments: []

  defimpl Poison.Encoder, for: __MODULE__ do
    def encode(struct, options) do

      # This is the format for GA report json
      # TODO: move into ReportRequest?
      Poison.Encoder.Map.encode(%{
        reportRequests: [
          %{
            view_id: to_string(struct.view_id),
            metrics: struct.metrics, # derived
            dimensions: struct.dimensions # derived
          }
        ]
      }, options)
    end
  end

  alias Legato.Profile
  alias Legato.Query.DateRange
  alias Legato.Query.Metric
  alias Legato.Query.MetricFilter
  alias Legato.Query.Dimension
  alias Legato.Query.DimensionFilter
  alias Legato.Query.FilterSet

  # TODO: Fetch this list from metadata api v3
  # https://developers.google.com/analytics/devguides/reporting/metadata/v3/
  @dimensions [
    # User
    :user_type,
    :session_count,
    :days_since_last_session,
    :user_defined_value,
    :user_bucket,

    # Session
    :session_duration_bucket,

    # Traffic Sources
    :referral_path,
    :full_referrer,
    :campaign,
    :source,
    :medium,
    :source_medium,
    :keyword,
    :ad_content,
    :social_network,
    :has_social_source_referral,
    :campaign_code,

    # Adwords
    :ad_group,
    :ad_slot,
    :ad_distribution_network,
    :ad_match_type,
    :ad_keyword_match_type,
    :ad_matched_query,
    :ad_placement_domain,
    :ad_placement_url,
    :ad_format,
    :ad_targeting_type,
    :ad_targeting_option,
    :ad_display_url,
    :ad_destination_url,
    :adwords_customer_id,
    :adwords_campaign_id,
    :adwords_ad_group_id,
    :adwords_creative_id,
    :adwords_criteria_id,
    :ad_query_word_count,
    :is_true_view_video_ad,

    # Goal Conversion
    :goal_completion_location,
    :goal_previous_step1,
    :goal_previous_step2,
    :goal_previous_step3,

    # Platform or Device
    :browser,
    :browser_version,
    :operating_system,
    :operating_system_version,
    :mobile_device_branding,
    :mobile_device_model,
    :mobile_input_selector,
    :mobile_device_info,
    :mobile_device_marketing_name,
    :device_category,
    :browser_size,
    :data_source,

    # Geo Network
    :continent,
    :sub_continent,
    :country,
    :region,
    :metro,
    :city,
    :latitude,
    :longitude,
    :network_domain,
    :network_location,
    :city_id,
    :continent_id,
    :country_iso_code,
    :metro_id,
    :region_id,
    :region_iso_code,
    :sub_continent_code,

    # System
    :flash_version,
    :java_enabled,
    :language,
    :screen_colors,
    :source_property_display_name,
    :source_property_tracking_id,
    :screen_resolution,

    # Page Tracking
    :hostname,
    :page_path,
    :page_path_level1,
    :page_path_level2,
    :page_path_level3,
    :page_path_level4,
    :page_title,
    :landing_page_path,
    :second_page_path,
    :exit_page_path,
    :previous_page_path,
    :page_depth,

    # Content Grouping
    # :landing_content_group_x_x,
    # :previous_content_group_x_x,
    # :content_group_x_x,

    # Internal Search
    :search_used,
    :search_keyword,
    :search_keyword_refinement,
    :search_category,
    :search_start_page,
    :search_destination_page,
    :search_after_destination_page,

    # App Tracking
    :app_installer_id,
    :app_version,
    :app_name,
    :app_id,
    :screen_name,
    :screen_depth,
    :landing_screen_name,
    :exit_screen_name,

    # Event Tracking
    :event_category,
    :event_action,
    :event_label,

    # Ecommerce
    :transaction_id,
    :affiliation,
    :sessions_to_transaction,
    :days_to_transaction,
    :product_sku,
    :product_name,
    :product_category,
    :currency_code,
    :checkout_options,
    :internal_promotion_creative,
    :internal_promotion_id,
    :internal_promotion_name,
    :internal_promotion_position,
    :order_coupon_code,
    :product_brand,
    :product_category_hierarchy,
    # :product_category_level_x_x,
    :product_coupon_code,
    :product_list_name,
    :product_list_position,
    :product_variant,
    :shopping_stage,

    # Social Interactions
    :social_interaction_network,
    :social_interaction_action,
    :social_interaction_network_action,
    :social_interaction_target,
    :social_engagement_type,

    # User Timings
    :user_timing_category,
    :user_timing_label,
    :user_timing_variable,

    # Exceptions
    :exception_description,

    # Content Experiments
    :experiment_id,
    :experiment_variant,

    # Custom Variables or Columns
    # :dimension_x_x,
    # :custom_var_name_x_x,
    # :custom_var_value_x_x,

    # Time
    :date,
    :year,
    :month,
    :week,
    :day,
    :hour,
    :minute,
    :nth_month,
    :nth_week,
    :nth_day,
    :nth_minute,
    :day_of_week,
    :day_of_week_name,
    :date_hour,
    :year_month,
    :year_week,
    :iso_week,
    :iso_year,
    :iso_year_iso_week,
    :nth_hour,

    # DoubleClick Campaign Manager
    :dcm_click_ad,
    :dcm_click_ad_id,
    :dcm_click_ad_type,
    :dcm_click_ad_type_id,
    :dcm_click_advertiser,
    :dcm_click_advertiser_id,
    :dcm_click_campaign,
    :dcm_click_campaign_id,
    :dcm_click_creative_id,
    :dcm_click_creative,
    :dcm_click_rendering_id,
    :dcm_click_creative_type,
    :dcm_click_creative_type_id,
    :dcm_click_creative_version,
    :dcm_click_site,
    :dcm_click_site_id,
    :dcm_click_site_placement,
    :dcm_click_site_placement_id,
    :dcm_click_spot_id,
    :dcm_floodlight_activity,
    :dcm_floodlight_activity_and_group,
    :dcm_floodlight_activity_group,
    :dcm_floodlight_activity_group_id,
    :dcm_floodlight_activity_id,
    :dcm_floodlight_advertiser_id,
    :dcm_floodlight_spot_id,
    :dcm_last_event_ad,
    :dcm_last_event_ad_id,
    :dcm_last_event_ad_type,
    :dcm_last_event_ad_type_id,
    :dcm_last_event_advertiser,
    :dcm_last_event_advertiser_id,
    :dcm_last_event_attribution_type,
    :dcm_last_event_campaign,
    :dcm_last_event_campaign_id,
    :dcm_last_event_creative_id,
    :dcm_last_event_creative,
    :dcm_last_event_rendering_id,
    :dcm_last_event_creative_type,
    :dcm_last_event_creative_type_id,
    :dcm_last_event_creative_version,
    :dcm_last_event_site,
    :dcm_last_event_site_id,
    :dcm_last_event_site_placement,
    :dcm_last_event_site_placement_id,
    :dcm_last_event_spot_id,

    # Audience
    :user_age_bracket,
    :user_gender,
    :interest_other_category,
    :interest_affinity_category,
    :interest_in_market_category,

    # Lifetime Value and Cohorts
    :acquisition_campaign,
    :acquisition_medium,
    :acquisition_source,
    :acquisition_source_medium,
    :acquisition_traffic_channel,
    :cohort,
    :cohort_nth_day,
    :cohort_nth_month,
    :cohort_nth_week,

    # Channel Grouping
    :channel_grouping,

    # Related Products
    :correlation_model_id,
    :query_product_id,
    :query_product_name,
    :query_product_variation,
    :related_product_id,
    :related_product_name,
    :related_product_variation,

    # DoubleClick Bid Manager
    :dbm_click_advertiser,
    :dbm_click_advertiser_id,
    :dbm_click_creative_id,
    :dbm_click_exchange,
    :dbm_click_exchange_id,
    :dbm_click_insertion_order,
    :dbm_click_insertion_order_id,
    :dbm_click_line_item,
    :dbm_click_line_item_id,
    :dbm_click_site,
    :dbm_click_site_id,
    :dbm_last_event_advertiser,
    :dbm_last_event_advertiser_id,
    :dbm_last_event_creative_id,
    :dbm_last_event_exchange,
    :dbm_last_event_exchange_id,
    :dbm_last_event_insertion_order,
    :dbm_last_event_insertion_order_id,
    :dbm_last_event_line_item,
    :dbm_last_event_line_item_id,
    :dbm_last_event_site,
    :dbm_last_event_site_id,

    # DoubleClick Search
    :ds_ad_group,
    :ds_ad_group_id,
    :ds_advertiser,
    :ds_advertiser_id,
    :ds_agency,
    :ds_agency_id,
    :ds_campaign,
    :ds_campaign_id,
    :ds_engine_account,
    :ds_engine_account_id,
    :ds_keyword,
    :ds_keyword_id
  ]

  @metrics [
    # User
    :users,
    :new_users,
    :percent_new_sessions,
    :"1day_users",
    :"7day_users",
    :"14day_users",
    :"30day_users",
    :sessions_per_user,

    # Session
    :sessions,
    :bounces,
    :bounce_rate,
    :session_duration,
    :avg_session_duration,
    :unique_dimension_combinations,
    :hits,

    # Traffic Sources
    :organic_searches,

    # Adwords
    :impressions,
    :ad_clicks,
    :ad_cost,
    :cpm,
    :cpc,
    :ctr,
    :cost_per_transaction,
    :cost_per_goal_conversion,
    :cost_per_conversion,
    :rpc,
    :roas,

    # Goal Conversions
    # :goal_x_x_starts,
    :goal_starts_all,
    # :goal_x_x_completions,
    :goal_completions_all,
    # :goal_x_x_value,
    :goal_value_all,
    :goal_value_per_session,
    # :goal_x_x_conversion_rate,
    :goal_conversion_rate_all,
    # :goal_x_x_abandons,
    :goal_abandons_all,
    # :goal_x_x_abandon_rate,
    :goal_abandon_rate_all,

    # Page Tracking
    :page_value,
    :entrances,
    :entrance_rate,
    :pageviews,
    :pageviews_per_session,
    :unique_pageviews,
    :time_on_page,
    :avg_time_on_page,
    :exits,
    :exit_rate,

    # Content Grouping
    # :content_group_unique_views_x_x,

    # Internal Search
    :search_result_views,
    :search_uniques,
    :avg_search_result_views,
    :search_sessions,
    :percent_sessions_with_search,
    :search_depth,
    :avg_search_depth,
    :search_refinements,
    :percent_search_refinements,
    :search_duration,
    :avg_search_duration,
    :search_exits,
    :search_exit_rate,
    # :search_goal_x_x_conversion_rate,
    :search_goal_conversion_rate_all,
    :goal_value_all_per_search,

    # Site Speed
    :page_load_time,
    :page_load_sample,
    :avg_page_load_time,
    :domain_lookup_time,
    :avg_domain_lookup_time,
    :page_download_time,
    :avg_page_download_time,
    :redirection_time,
    :avg_redirection_time,
    :server_connection_time,
    :avg_server_connection_time,
    :server_response_time,
    :avg_server_response_time,
    :speed_metrics_sample,
    :dom_interactive_time,
    :avg_dom_interactive_time,
    :dom_content_loaded_time,
    :avg_dom_content_loaded_time,
    :dom_latency_metrics_sample,

    # App Tracking
    :screenviews,
    :unique_screenviews,
    :screenviews_per_session,
    :time_on_screen,
    :avg_screenview_duration,

    # Event Tracking
    :total_events,
    :unique_events,
    :event_value,
    :avg_event_value,
    :sessions_with_event,
    :events_per_session_with_event,

    # Ecommerce
    :transactions,
    :transactions_per_session,
    :transaction_revenue,
    :revenue_per_transaction,
    :transaction_revenue_per_session,
    :transaction_shipping,
    :transaction_tax,
    :total_value,
    :item_quantity,
    :unique_purchases,
    :revenue_per_item,
    :item_revenue,
    :items_per_purchase,
    :local_transaction_revenue,
    :local_transaction_shipping,
    :local_transaction_tax,
    :local_item_revenue,
    :buy_to_detail_rate,
    :cart_to_detail_rate,
    :internal_promotion_c_t_r,
    :internal_promotion_clicks,
    :internal_promotion_views,
    :local_product_refund_amount,
    :local_refund_amount,
    :product_adds_to_cart,
    :product_checkouts,
    :product_detail_views,
    :product_list_c_t_r,
    :product_list_clicks,
    :product_list_views,
    :product_refund_amount,
    :product_refunds,
    :product_removes_from_cart,
    :product_revenue_per_purchase,
    :quantity_added_to_cart,
    :quantity_checked_out,
    :quantity_refunded,
    :quantity_removed_from_cart,
    :refund_amount,
    :revenue_per_user,
    :total_refunds,
    :transactions_per_user,

    # Social Interactions
    :social_interactions,
    :unique_social_interactions,
    :social_interactions_per_session,

    # User Timings
    :user_timing_value,
    :user_timing_sample,
    :avg_user_timing_value,

    # Exceptions
    :exceptions,
    :exceptions_per_screenview,
    :fatal_exceptions,
    :fatal_exceptions_per_screenview,

    # Custom Variables or Columns
    # :metric_x_x,
    # :calc_metric_,

    # DoubleClick Campaign Manager
    :dcm_floodlight_quantity,
    :dcm_floodlight_revenue,
    :dcm_c_p_c,
    :dcm_c_t_r,
    :dcm_clicks,
    :dcm_cost,
    :dcm_impressions,
    :dcm_r_o_a_s,
    :dcm_r_p_c,

    # Adsense
    :adsense_revenue,
    :adsense_ad_units_viewed,
    :adsense_ads_viewed,
    :adsense_ads_clicks,
    :adsense_page_impressions,
    :adsense_c_t_r,
    :adsense_e_c_p_m,
    :adsense_exits,
    :adsense_viewable_impression_percent,
    :adsense_coverage,

    # Ad Exchange
    :adx_impressions,
    :adx_coverage,
    :adx_monetized_pageviews,
    :adx_impressions_per_session,
    :adx_viewable_impressions_percent,
    :adx_clicks,
    :adx_c_t_r,
    :adx_revenue,
    :adx_revenue_per1000_sessions,
    :adx_e_c_p_m,

    # DoubleClick for Publishers
    :dfp_impressions,
    :dfp_coverage,
    :dfp_monetized_pageviews,
    :dfp_impressions_per_session,
    :dfp_viewable_impressions_percent,
    :dfp_clicks,
    :dfp_c_t_r,
    :dfp_revenue,
    :dfp_revenue_per1000_sessions,
    :dfp_e_c_p_m,

    # DoubleClick for Publishers Backfill
    :backfill_impressions,
    :backfill_coverage,
    :backfill_monetized_pageviews,
    :backfill_impressions_per_session,
    :backfill_viewable_impressions_percent,
    :backfill_clicks,
    :backfill_c_t_r,
    :backfill_revenue,
    :backfill_revenue_per1000_sessions,
    :backfill_e_c_p_m,

    # Lifetime Value and Cohorts
    :cohort_active_users,
    :cohort_appviews_per_user,
    :cohort_appviews_per_user_with_lifetime_criteria,
    :cohort_goal_completions_per_user,
    :cohort_goal_completions_per_user_with_lifetime_criteria,
    :cohort_pageviews_per_user,
    :cohort_pageviews_per_user_with_lifetime_criteria,
    :cohort_retention_rate,
    :cohort_revenue_per_user,
    :cohort_revenue_per_user_with_lifetime_criteria,
    :cohort_session_duration_per_user,
    :cohort_session_duration_per_user_with_lifetime_criteria,
    :cohort_sessions_per_user,
    :cohort_sessions_per_user_with_lifetime_criteria,
    :cohort_total_users,
    :cohort_total_users_with_lifetime_criteria,

    # Related Products
    :correlation_score,
    :query_product_quantity,
    :related_product_quantity,

    # DoubleClick Bid Manager
    :dbm_c_p_a,
    :dbm_c_p_c,
    :dbm_c_p_m,
    :dbm_c_t_r,
    :dbm_clicks,
    :dbm_conversions,
    :dbm_cost,
    :dbm_impressions,
    :dbm_r_o_a_s,

    # DoubleClick Search
    :ds_c_p_c,
    :ds_c_t_r,
    :ds_clicks,
    :ds_cost,
    :ds_impressions,
    :ds_profit,
    :ds_return_on_ad_spend,
    :ds_revenue_per_click
  ]

  @doc ~S"""
  Start a query with a given Legato.Profile and metrics

  ## Examples

    iex> %Legato.Profile{access_token: "abcde", view_id: 177817} |> Legato.Query.metrics([:pageviews])
    %Legato.Query{
      profile: %Legato.Profile{access_token: "abcde", view_id: 177817},
      view_id: 177817,
      metrics: [%Legato.Query.Metric{expression: "ga:pageviews"}]
    }

  """
  def metrics(%Profile{} = profile, names) do
    %__MODULE__{profile: profile, view_id: profile.view_id} |> metrics(names)
  end

  @doc ~S"""
  Add metrics to an existing Legato.Query

  ## Examples

    iex> %Legato.Query{} |> Legato.Query.metrics([:pageviews]) |> Legato.Query.metrics([:exits])
    %Legato.Query{
      metrics: [%Legato.Query.Metric{expression: "ga:pageviews"}, %Legato.Query.Metric{expression: "ga:exits"}]
    }

  """
  def metrics(%__MODULE__{} = query, names) do
    %{query | metrics: Metric.add(query.metrics, names)}
  end

  @doc ~S"""
  Start a query with a given Legato.Profile and dimensions

  ## Examples

    iex> %Legato.Profile{access_token: "abcde", view_id: 177817} |> Legato.Query.dimensions([:country])
    %Legato.Query{
      profile: %Legato.Profile{access_token: "abcde", view_id: 177817},
      view_id: 177817,
      dimensions: [%Legato.Query.Dimension{name: "ga:country"}]
    }

  """
  def dimensions(%Profile{} = profile, names) do
    %__MODULE__{profile: profile, view_id: profile.view_id} |> dimensions(names)
  end

  @doc ~S"""
  Add dimensions to an existing Legato.Query

  ## Examples

    iex> %Legato.Query{} |> Legato.Query.dimensions([:country]) |> Legato.Query.dimensions([:city])
    %Legato.Query{
      dimensions: [%Legato.Query.Dimension{name: "ga:country"}, %Legato.Query.Dimension{name: "ga:city"}]
    }

  """
  def dimensions(%__MODULE__{} = query, names) do
    %{query | dimensions: Dimension.add(query.dimensions, names)}
  end

  @doc ~S"""
  Add filter to set for dimensions and metrics

  Checks for the name of the dimension or metric in a predefined set.
  If the value is dynamic (e.g. custom variables like `:dimension_x_x`)
    it will not know if it is a dimension or metric name.
  This limitation can be circumvented creating the MetricFilter or
    DimensionFilter struct yourself.

  ## Examples

    iex> %Legato.Query{} |> Legato.Query.filter(:pageviews, :gt, 10)
    %Legato.Query{
      filters: %{
        dimensions: %Legato.Query.FilterSet{as: :dimensions},
        metrics: %Legato.Query.FilterSet{as: :metrics, operator: :or, filters: [
          %Legato.Query.MetricFilter{
            metric_name: :pageviews,
            not: false,
            operator: :gt,
            comparison_value: 10
          }
        ]}
      }
    }

    iex> %Legato.Query{} |> Legato.Query.filter(:continent, :like, ["North America", "Europe"])
    %Legato.Query{
      filters: %{
        metrics: %Legato.Query.FilterSet{as: :metrics},
        dimensions: %Legato.Query.FilterSet{as: :dimensions, operator: :or, filters: [
          %Legato.Query.DimensionFilter{
            dimension_name: :continent,
            not: false,
            operator: :like,
            case_sensitive: false,
            expressions: ["North America", "Europe"]
          }
        ]}
      }
    }

  """
  def filter(query, name, operator, value) when name in(@metrics) do
    filter(query, %MetricFilter{
      metric_name: name,
      operator: (operator || :equal),
      comparison_value: value
    })
  end

  def filter(query, name, operator, expressions) when name in(@dimensions) do
    filter(query, %DimensionFilter{
      dimension_name: name,
      operator: (operator || :regexp),
      expressions: expressions
    })
  end

  def filter(query, %MetricFilter{} = filter) do
    update_in(query.filters.metrics, &FilterSet.add(&1, filter))
  end

  def filter(query, %DimensionFilter{} = filter) do
    update_in(query.filters.dimensions, &FilterSet.add(&1, filter))
  end

  # add to existing date ranges
  def between(query, start_date, end_date) do
    %{query | date_ranges: DateRange.add(query.date_ranges, start_date, end_date)}
  end

  # TODO: validate presence of profile, view_id, metrics, dimensions

  # TODO: order_by(s)

  def to_json(query), do: Poison.encode!(query)
end
