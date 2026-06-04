# typed: true
# frozen_string_literal: true

require "passkit"
require "passkit/generator"

module Passkit
  class Generator
    module SupportGenerationWithoutBarcodes
      extend T::Sig
      extend T::Helpers

      requires_ancestor { Generator }

      def generate_json_pass
        pass = {
          formatVersion: @pass.format_version,
          teamIdentifier: @pass.apple_team_identifier,
          authenticationToken: @pass.authentication_token,
          backgroundColor: @pass.background_color,
          description: @pass.description,
          foregroundColor: @pass.foreground_color,
          labelColor: @pass.label_color,
          locations: @pass.locations,
          logoText: @pass.logo_text,
          organizationName: @pass.organization_name,
          passTypeIdentifier: @pass.pass_type_identifier,
          serialNumber: @pass.serial_number,
          sharingProhibited: @pass.sharing_prohibited,
          suppressStripShine: @pass.suppress_strip_shine,
          voided: @pass.voided,
          webServiceURL: @pass.web_service_url,
        }

        pass[:maxDistance] = @pass.max_distance if @pass.max_distance
        pass[:barcodes] = @pass.barcodes

        pass[:appLaunchURL] = @pass.app_launch_url if @pass.app_launch_url
        pass[:associatedStoreIdentifiers] = @pass.associated_store_identifiers unless @pass.associated_store_identifiers.empty?
        pass[:beacons] = @pass.beacons unless @pass.beacons.empty?
        pass[:boardingPass] = @pass.boarding_pass if @pass.boarding_pass
        pass[:coupon] = @pass.coupon if @pass.coupon
        pass[:eventTicket] = @pass.event_ticket if @pass.event_ticket
        pass[:expirationDate] = @pass.expiration_date if @pass.expiration_date
        pass[:generic] = @pass.generic if @pass.generic
        pass[:groupingIdentifier] = @pass.grouping_identifier if @pass.grouping_identifier
        pass[:nfc] = @pass.nfc if @pass.nfc
        pass[:relevantDate] = @pass.relevant_date if @pass.relevant_date
        pass[:semantics] = @pass.semantics if @pass.semantics
        pass[:store_card] = @pass.store_card if @pass.store_card
        pass[:userInfo] = @pass.user_info if @pass.user_info

        pass[@pass.pass_type] = {
          headerFields: @pass.header_fields,
          primaryFields: @pass.primary_fields,
          secondaryFields: @pass.secondary_fields,
          auxiliaryFields: @pass.auxiliary_fields,
          backFields: @pass.back_fields,
        }

        File.write(@temporary_path.join("pass.json"), pass.to_json)
      end
    end

    prepend SupportGenerationWithoutBarcodes
  end
end
